/** Local integration check. Creates explicitly named test records; never run on production. */
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';

const base = process.env.DIKU_TEST_URL || 'http://localhost:8088';
const url = new URL(base);
assert(['localhost', '127.0.0.1'].includes(url.hostname), 'Only local test URLs are allowed.');

const titles = new Set();
for (const path of ['/', '/kurzusok', '/szuloknek', '/diakoknak', '/erettsegi-feladatsorok', '/programozas-izelito', '/jelentkezes', '/oktatas-menete', '/oktatok', '/arak', '/gyik', '/helyszin', '/kapcsolat', '/adatkezeles', '/impresszum', '/belepes', '/admin', '/tanulo']) {
  const response = await fetch(base + path);
  assert.equal(response.status, 200, `${path} must be directly reachable`);
  const html = await response.text();
  const title = html.match(/<title>(.*?)<\/title>/)?.[1];
  assert(title && !titles.has(title), `${path} must have a unique static title`);
  titles.add(title);
  assert.equal((html.match(/<h1(?:\s|>)/g) || []).length, 1, `${path} must contain one prerendered H1`);
  assert(html.includes(`https://diku-erettsegi.hu${path === '/' ? '' : path}`), `${path} canonical missing`);
  if (['/belepes', '/admin', '/tanulo', '/programozas-izelito'].includes(path)) assert(html.includes('noindex'), 'Private/draft pages must not be indexed');
}
assert.equal((await fetch(base + '/nincs-ilyen-oldal')).status, 404, 'Unknown route must return real HTTP 404');
const redirect = await fetch(base + '/arak/', { redirect: 'manual' });
assert([301, 308].includes(redirect.status), 'Trailing slash route must redirect');
assert.equal(new URL(redirect.headers.get('location'), base).pathname, '/arak');
assert.equal((await fetch(base + '/sitemap.xml')).status, 200);
assert.equal((await fetch(base + '/robots.txt')).status, 200);
console.log('PASS: real nginx routes, static SEO metadata/H1, private noindex, 404, redirect, sitemap, robots.');

class Session {
  cookie = '';
  csrf = null;
  async request(path, { method = 'GET', body, expected = 200 } = {}) {
    const headers = {};
    if (this.cookie) headers.Cookie = this.cookie;
    if (this.csrf && !['GET', 'HEAD'].includes(method)) headers[this.csrf.headerName] = this.csrf.token;
    if (body && !(body instanceof FormData)) { headers['Content-Type'] = 'application/json'; body = JSON.stringify(body); }
    const response = await fetch(base + path, { method, headers, body, redirect: 'manual' });
    for (const entry of response.headers.getSetCookie()) {
      if (entry.startsWith('JSESSIONID=')) this.cookie = entry.split(';')[0];
    }
    const data = await response.text();
    assert.equal(response.status, expected, `${method} ${path}: expected ${expected}, got ${response.status}: ${data.slice(0, 400)}`);
    try { return JSON.parse(data); } catch { return data; }
  }
  async token() { this.csrf = await this.request('/api/auth/csrf'); }
  async login(email, password) {
    await this.token();
    const user = await this.request('/api/auth/login', { method: 'POST', body: { email, password } });
    await this.token();
    return user;
  }
}

const stamp = Date.now();
const anonymous = new Session();
await anonymous.request('/api/auth/me', { expected: 401 });
await anonymous.request('/api/admin/users', { expected: 401 });
await anonymous.request('/api/applications', { method: 'POST', body: {}, expected: 403 });
await anonymous.token();
await anonymous.request('/api/applications', { method: 'POST', expected: 400, body: { studentName: 'Teszt', email: 'hibás', phone: '123', privacyAccepted: false } });
const courses = await anonymous.request('/api/courses');
assert.equal(courses.length, 2, 'The two configured groups must be returned');
const course = courses.find(item => item.registrationOpen && item.availableSeats > 0);
assert(course, 'A local test group must have space');
assert.equal(course.capacity, 24);
assert.equal(course.sessions * course.lessonsPerSession, 80);
assert.equal(course.price.baseTotal, 280000);
const applicationBody = { studentName: `Automata teszt ${stamp}`, email: `test-${stamp}@example.com`, phone: '+36 30 123 4567', parentName: 'Teszt szülő', message: 'Helyi integrációs teszt. Törölhető adat.', privacyAccepted: true, courseId: course.id, requestId: randomUUID(), friendCount: 2, referralNote: 'Két barát, adminnal egyeztetendő.', laptopRentalRequested: true };
const application = await anonymous.request('/api/applications', {
  method: 'POST', expected: 201, body: applicationBody,
});
assert(application.id, 'Application must persist an ID');
const expectedDiscount = Math.min(35, course.price.periodDiscountPercent + applicationBody.friendCount * 5);
assert.equal(application.discountPercent, expectedDiscount);
assert.equal(application.quotedTotal, course.price.baseTotal * (100 - expectedDiscount) / 100, 'Server quote must stack and cap discounts');
assert.equal((await anonymous.request('/api/applications', { method: 'POST', expected: 201, body: applicationBody })).id, application.id, 'Network retry must not duplicate application');
await anonymous.request('/api/applications', { method: 'POST', expected: 409, body: { ...applicationBody, studentName: 'Eltérő név' } });
const interestBody = { name: `Programozós teszt ${stamp}`, email: `preview-${stamp}@example.com`, privacyAccepted: true, requestId: randomUUID() };
await new Session().request('/api/programming-interests', { method: 'POST', body: interestBody, expected: 403 });
const interest = await anonymous.request('/api/programming-interests', { method: 'POST', body: interestBody, expected: 201 });
assert.equal((await anonymous.request('/api/programming-interests', { method: 'POST', body: interestBody, expected: 201 })).id, interest.id, 'Interest retry must not duplicate record');

const admin = new Session();
assert.equal((await admin.login('admin@diku.local', 'DikuAdmin2026!')).role, 'ADMIN');
const applications = await admin.request('/api/admin/applications');
assert(applications.some(item => item.id === application.id), 'Admin must see submitted application');
const saved = applications.find(item => item.id === application.id);
assert.equal(saved.courseId, course.id);
assert.equal(saved.quotedTotal, application.quotedTotal);
assert.equal(saved.friendCount, 2);
assert.equal(saved.friendDiscountStatus, 'PENDING_ADMIN');
assert.equal(saved.laptopRentalRequested, true);
assert(saved.createdAt.endsWith('Z') && Number.isFinite(Date.parse(saved.createdAt)), 'Server timestamp must be stored in UTC');
const filtered = await admin.request(`/api/admin/applications?courseId=${course.id}`);
assert(filtered.some(item => item.id === application.id) && filtered.every(item => item.courseId === course.id));
await admin.request(`/api/admin/applications/${application.id}`, { method: 'PATCH', body: { status: 'CONTACTED', notes: 'Automata teszt, kapcsolatfelvétel kipróbálva.' } });
const updated = (await admin.request('/api/admin/applications')).find(item => item.id === application.id);
assert.equal(updated.quotedTotal, saved.quotedTotal);
assert.equal(updated.createdAt, saved.createdAt);
assert((await admin.request('/api/admin/programming-interests')).some(item => item.id === interest.id));

const originalInterest = (await admin.request('/api/admin/programming-interests')).find(item => item.id === interest.id);
assert.equal(originalInterest.status, 'NEW');
await admin.request(`/api/admin/programming-interests/${interest.id}`, { method: 'PATCH', body: { status: 'CONTACTED', notes: 'Kézi kapcsolatfelvétel helyi tesztje.' } });
const processedInterest = (await admin.request('/api/admin/programming-interests')).find(item => item.id === interest.id);
assert.equal(processedInterest.status, 'CONTACTED');
assert.equal(processedInterest.notes, 'Kézi kapcsolatfelvétel helyi tesztje.');
assert.equal(processedInterest.createdAt, originalInterest.createdAt);
assert(Number.isFinite(Date.parse(processedInterest.updatedAt)));
console.log('PASS: group selection/filter, stacked discounts, immutable quote/date, idempotency and manual interest management.');
const lesson = await admin.request('/api/admin/lessons', { method: 'POST', expected: 201, body: { title: `Tesztóra ${stamp}`, description: 'Helyi teszt, törölhető.', startsAt: '2026-11-01T15:00:00', meetingUrl: 'https://teams.microsoft.com/', published: false } });
const form = new FormData();
form.append('file', new Blob(['DIKU integration test file'], { type: 'text/plain' }), 'diku-test.txt');
const uploaded = await admin.request(`/api/admin/lessons/${lesson.id}/files`, { method: 'POST', body: form, expected: 201 });
assert(uploaded.id, 'Uploaded file ID required');

const student = new Session();
assert.equal((await student.login('diak@diku.local', 'DikuDiak2026!')).role, 'STUDENT');
await student.request('/api/admin/users', { expected: 403 });
await student.request('/api/admin/programming-interests', { expected: 403 });
assert(!(await student.request('/api/lessons')).some(item => item.id === lesson.id), 'Draft lesson must stay private');
await student.request(`/api/files/${uploaded.id}/download`, { expected: 404 });
await admin.request(`/api/admin/lessons/${lesson.id}`, { method: 'PUT', body: { title: lesson.title, description: lesson.description, startsAt: lesson.startsAt, meetingUrl: lesson.meetingUrl, published: true } });
assert((await student.request('/api/lessons')).some(item => item.id === lesson.id), 'Published lesson must appear');
assert.equal(await student.request(`/api/files/${uploaded.id}/download`), 'DIKU integration test file');

const createdUser = await admin.request('/api/admin/users', { method: 'POST', expected: 201, body: { name: 'Automata teszt diák', email: `student-${stamp}@example.com`, password: 'SmokeTestPassword2026!', role: 'STUDENT' } });
const temporary = new Session();
await temporary.login(createdUser.email, 'SmokeTestPassword2026!');
await admin.request(`/api/admin/users/${createdUser.id}`, { method: 'PATCH', body: { name: createdUser.name, email: createdUser.email, role: 'STUDENT', enabled: false } });
await temporary.request('/api/auth/me', { expected: 401 });
assert((await admin.request('/api/admin/audit')).length > 0, 'Audit must record admin actions');
await admin.request(`/api/admin/files/${uploaded.id}`, { method: 'DELETE', expected: 204 });
await admin.request(`/api/admin/lessons/${lesson.id}`, { method: 'DELETE', expected: 204 });
await student.request('/api/auth/logout', { method: 'POST', expected: 204 });
await student.request('/api/lessons', { expected: 401 });
console.log('PASS: CSRF, application, admin status, login, roles, lessons, protected file upload/download, disabled-session revocation, audit, logout.');
console.log(`Local test application ${application.id}, programming interest ${interest.id} and disabled test user ${createdUser.id} remain for inspection.`);
