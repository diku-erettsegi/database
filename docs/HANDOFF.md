# Átadás – 2026. október 25.

## Legfrissebb DNS-ellenőrzés – október 25.

A felhasználó átállította a névszervereket, majd ellenőrzést kért. A `.hu` szülőzóna közvetlen lekérdezése, valamint Google és Cloudflare DoH az alexa/gerardo Cloudflare-párt igazolja; DS nincs. A Cloudflare dashboard még pending; a kézi **Check nameservers now** elindult. Apex Tunnel és www CNAME Proxied, mail/MX megőrizve; rekordot nem módosítottunk. Négy VPS-konténer healthy, de publikus HTTP/HTTPS még sikertelen a DNS/aktiválási állapot miatt. Ez felülírja az alábbi halasztást: a regisztrátori váltást már ne kérd újra. Következő feladat az aktív zóna, HTTPS és külső alkalmazáspróbák ellenőrzése. Teljes mérési eredmény és korlát: [DEPLOY-STATUS](DEPLOY-STATUS.md). Nem állítottunk be időzített követést, alkalmazásadat nem változott.

## Telepítési munka – október 24. (történeti állapot)

A felhasználó október 23-án a tényleges deploy folytatását kérte; október 24-én is ez a munka folytatódik. A **[DEPLOY-STATUS](DEPLOY-STATUS.md)** az irányadó élő állapot. Docker Engine 29.9.2, Compose v5.6.1 és `diku-deploy` telepítve; a három repó első main pushja és mindhárom CI sikeres. Az infra klón `/opt/diku/database`, a production env privátan elkészült, a valódi VPS-preflight és a systemd unitok ellenőrzése sikeres.

Október 24-én a felhasználó nyilvánossá tette a két GHCR image-et; a VPS `diku-deploy` felhasználójával a névtelen pull és az első teljes deploy sikeres. **17:37 Budapest időtől mindkét timer enabled/active.** A frontend és backend dokumentációs main pushja után mindkét CI és a teljes automatikus VPS-frissítés PASS; API-kód nem változott. A 23:02-es ellenőrzéskor a deploy service success/0, az új digestpár `.release.env`-ben rögzítve; a frissítés óta ellenőrzött változatlan kiadású körök „Nincs új kiadás” eredményűek. A végleges digestek egyeznek a GHCR main/teljes SHA tagjeivel, a teljes normalizált DB dump mindkét deploy előtti mentéssel egyezik. Pontos digestek és mentések: DEPLOY-STATUS. A `diku-erettsegi` Tunnel tokenje fájl-secretből érkezik.

A `backups/20261024T090312-248340` alkalmazásmentésből az izolált `diku-restore-20261024153350` restore **PASS**: checksums, SQL import és normalizált dump byte-egyezés, tar diff, visszatöltött backend UP és `/api/courses`. Uploadarchívum üres, valódi tananyagbyte-próba nincs; tesztkonténerek leállítva, külön volume-ok megőrizve. Az éles belső Nginx → API admin-auth próba is PASS: login/sessionrotáció, Secure/HttpOnly, CSRF 403, anonim admin 401, no-store, két csoport, logout. Bootstrap env értékek kivéve; a backend újralétrehozása utáni healthy állapot igazolt. Az adminadatok a helyi, Gitből kizárt `database/secrets/initial-admin.txt` átadófájlban vannak; tartalmát ne olvasd dokumentációba vagy naplóba.

A Cloudflare Free zóna **Pending Nameserver Update** állapotban. Kiosztott névszerverei `alexa.ns.cloudflare.com` és `gerardo.ns.cloudflare.com`; a felhasználó legfrissebb utasítása szerint a Microware-nél a váltást később végzi el, **most kihagyjuk**. Ez felülírja az esetleges korábbi átállításra utaló közlést. A Tunnel `diku-erettsegi.hu` → `http://frontend:80` route-ja mentve, az apex proxizott Tunnel CNAME, a www proxizott CNAME az apexre. A `mail` A és wildcard A DNS only, az MX prioritás 5 megőrizve; a felületen visszaolvasva. A felhasználó szerint nincs használt levelezés/aldomain, későbbi levelezését maga intézi; a meglévő rekordokat nem töröltük.

A publikus domain/HTTPS-próba a névszerverváltással együtt későbbre halasztva. A Cloudflare www → apex 301 útvonal/query megőrzéssel mentve, Always Use HTTPS bekapcsolva, minimum TLS 1.2; edge tanúsítvány még nincs a pending NS miatt. A **DIKU private and API bypass** szabály Active: API/admin/tanuló/belépés prefix vagy JSESSIONID cookie → Bypass cache. Külső mentés/riasztás nincs bekötve. A korábbi október 22-i, „csak előkészített / nincs push” bejegyzések történeti állapotok; az alábbi dátumozott teszteredmények változatlanok. Folytatáskor az élő állapotot ellenőrizd, a korábbi előkészítést ne ismételd automatikusan.

Záró VPS-próba PASS: négy healthy konténer, nincs hostport, bootstrap admin email/jelszó vagy pending/recovery állapot. Belső főoldal/kurzusok/courses API 200, anonim admin 401, ismeretlen oldal 404, no-store rendben. A `diku-backup.service` kézi systemd-indítása success/0; mentés `20261024T210241-588022`, backend utána healthy. A napi timer naptára külön ellenőrzött, következő futás 2026-10-25 03:34:37 CET; ez még jövőbeli esemény, nem kell rá várni a telepítés lezárásához. Záró lemezfoglaltság 28%, 21 GB szabad.

## Helyi rendszer

React + TypeScript + Vite, Java 21 / Spring Boot 3.5.16 és MariaDB 11.4, három külön Git repóban. Web: **http://localhost:8088**; belépés `/belepes`, admin `/admin`, tanuló `/tanulo`. Indítás a database mappából: `docker compose up -d --build --wait`. Leállítás: `docker compose down`; a volume-okat őrizd meg.

Helyi admin: `admin@diku.local` / `DikuAdmin2026!`; tanuló: `diak@diku.local` / `DikuDiak2026!`. Csak local profilú tesztadatok. Backend 8080, DB 3308, valamennyi hostport loopbackre kötött. Másik projekt adatbázisa is fut a gépen; ahhoz és annak volume-jaihoz ne nyúlj.

A három kezdetben üres repó első main pushja és CI-futása sikeres; a pontos commit/push/CI állapot a DEPLOY-STATUS-ban. A szülőmappa README/AGENTS helyi útbaigazító, nem negyedik repó.

## Deploy-előkészítés – október 22.

A felhasználó most a Rackforest Ubuntu VPS automatikus Docker-telepítési stratégiáját kérte és helyben SSH-hozzáférést adott. A sikeres, csak olvasási felmérés: Ubuntu 24.04.5 LTS, x86_64, 1 vCPU / 4 GB RAM, kb. 23 GB szabad lemez; Docker és Compose nincs telepítve. Root/jelszavas SSH jelenleg engedélyezett. A szerveren konfigurációs módosítás nem történt. Részletek: [SERVER-AUDIT](SERVER-AUDIT-2026-10-22.md).

- A [DEPLOYMENT](DEPLOYMENT.md) konkrét egyszeri telepítést, GitHub/GHCR jogosultságokat, indulást, frissítést és helyreállítást ír le. A frontend/backend main CI publikál, a szerver kétpercenként ellenőriz; az infra-repó változása továbbra is felügyelt.
- [CLOUDFLARE-SETUP](CLOUDFLARE-SETUP.md): a domain marad a magyar regisztrátornál, Cloudflare névszerverek és kimenő Tunnel szolgálják ki. A jelenlegi NS/MX leolvasva; teljes DNS-leltár és Cloudflare-hozzáférés még nincs. DNS-módosítás nem történt, a levelezési rekordokat meg kell őrizni.
- Productionben nincs hostport, a MariaDB/cloudflared image digest rögzített. A Tunnel token külön file-secret; hoston 0700 szülőmappa / 0644 tokenfájl a cloudflared 65532 UID olvashatóságához. Nincs valódi token az env-mintában.
- Új `scripts/preflight.sh`: csak olvasó Linux-ellenőrzés, envet nem futtat, Compose JSON/titkok nem kerülnek naplóba. Fájljogok, production profil/cookie, digest, secret és hostportok ellenőrzése.
- Deploy: a `.release.env` csak egészséges kiadás után módosul. Külön pending/failed/recovery állapot, megszakítás utáni helyreállítás, hibás párok elkülönítése, explicit `--retry-failed`. Leállt meglévő DB mellett nem indulhat új migráció mentés nélkül. Hibás rollback blokkolja az automatikus folytatást.
- Konzisztens DB/fájlbackup ellenőrzőösszeggel. Deploy alatt a mentéstől az új indulásig nincs köztes backendírás. Napi 03:30 Budapest backup timer; hiba után 5 percenként, legfeljebb 3 indulás két órán belül. Mindkét timer csak előkészített, nincs telepítve.
- Nginx törli az alternatív kliens Forwarded/proxy fejléceket. A frontend CI most valódi Nginx + echo backend regressziót is futtat. A javítást tartalmazó helyi frontend október 22-én újraépült és healthy; az alkalmazásadatokat nem módosítottuk.

Igazolt ellenőrzések: **22/22** deploy/backup regresszió és **40/40** preflight eset izolált Linux-konténerekben, fake Dockerrel; Bash szintaxis; local/production Compose config; mindhárom workflow actionlint. Valódi Nginx proxyregresszió sikeres; a frontend Docker build során a 18 útvonal + 404 és a 6/6 SEO teszt újra sikeres. A VPS systemd 255 olvasási naptárellenőrzése elfogadja a `03:30:00 Europe/Budapest` ütemezést. A mock tesztek nem jelentenek valódi production deploy/restore próbát.

Hiányzó éles lépések: első GitHub push és CI, Docker/operátori hozzáférés/GHCR-konfiguráció, Cloudflare-zóna és token, DNS-átállítás, első admin, staging update/rollback és tényleges backup/restore, külső mentési cél/retention/riasztás, végleges publikus tartalom. A rövid kiesés és sessionvesztés vállalt; DB-migráció automatikusan nem fordul vissza. A root secret.txt tartalmát ne jelenítsd meg, ne másold repóba. Az SSH első kulcsa helyben TOFU-val, Gitből kizárt `.deploy/ssh_known_hosts` fájlban rögzített; ez nem független konzolos hitelesítés.

## Az októberi stratégia megvalósítása

- Krém/zöld főoldal két valódi, helyben kiszolgált Pexels-stockfotóval. Illusztrációként jelöltek, nem saját oktatót vagy helyszínt ábrázolnak. AI-kép nincs a publikus assetek között. Eredet/licenc: [IMAGE-ASSETS](IMAGE-ASSETS.md).
- 18 előrenderelt útvonal + valódi 404. Kiemelt `/kurzusok` CTA, `/szuloknek`, `/diakoknak`, `/erettsegi-feladatsorok`; a `/jelentkezes` is működik. Egyedi title/description/canonical és egy H1; sitemap, robots, Open Graph és alap JSON-LD. Privát felületek, jogi piszkozatok és programozási ízelítő noindex.
- Kezdés: 2027. január 9.; 20 alkalom, 80 × 45 perc. Két szombati csoport 09–13 és 14–18 között, legfeljebb 24 fő/csoport. Balázs és Peti közösen oktat, helyszín Gábor Dénes Egyetem, XI. kerület. Ismeretlen portré, terem, telefon és részletes feltételek helyőrzők maradtak.
- Jelentkezés csoporttal, barátszámmal, ajánlásjelölővel, laptopigénnyel és megjegyzéssel. Admin csoport-/státuszszűrés, jelentkezési időpont, mentett díj és kedvezménybontás.
- 280 000 Ft alapdíj; 25% november 15. végéig, 15% december 15. végéig, Europe/Budapest szerint. Barátonként 5%; a kedvezmények összeadódnak **maximum 35%-ig**. 25% + két barát = 182 000 Ft, azaz 2 275 Ft/tanóra. A backend változatlan ár-pillanatképet és UTC beküldési időpontot ment. A baráti jogosultságot kézzel egyeztetik.
- Programozási érdeklődés külön formon és adminmenüben: NEW / CONTACTED / COMPLETED, belső megjegyzés, módosítás ideje. **Nincs automatikus e-mail, SMTP, küldő worker vagy Mailpit szolgáltatás.** A szervezők saját levelezőjükből küldik a linket; a felület csak a mentést igazolja.
- Öt OH-vizsgaidőszak húsz eredeti PDF/ZIP linkje. 2026-10-20-án valamennyi GET 200 és megfelelő fájlszignatúra; nincs saját tárhelyre tükrözés.
- A tanulói órák/fájlok, dátum és HTTPS értekezletlink, admin órakezelés/feltöltés, felhasználókezelés és audit megmaradt.

## Adat- és API-szerződés

Részletek: [STRATEGY](STRATEGY-2026-10.md), [architektúra](ARCHITECTURE.md), [API](../../backend/API.md), [döntések](DECISIONS.md).

V1/V2 változatlan; V3 adja a kedvezménybontást és manuális érdeklődőkezelést. Régi, csoport nélküli jelentkezések és korábbi árak megmaradnak. A V2 történeti `mail_outbox` táblája használaton kívül marad; ne írd át a migráció checksumját.

UUID requestId és azonos normalizált tartalom ismétlése ugyanazt a rekordot és mentett árat adja; eltérő tartalom ugyanazzal UUID-val 409. DB egyedi korlátozás és tranzakció védi a párhuzamos kéréseket.

NEW/CONTACTED nem foglal férőhelyet; ACCEPTED igen. Elfogadáskor csoportsor-zárolás és újraszámolás védi a 24 fős limitet. Visszavonás helyet szabadít fel. Betelt/lezárt csoportba nincs új nyilvános jelentkezés; meglévő sikeres kérés idempotens újrapróbálása működik.

Session/CSRF, BCrypt, backend szerepkör-ellenőrzés, privát UUID fájltároló, publikáltság alapján engedett letöltés, letiltott user sessionjének visszavonása, utolsó aktív admin védelme. Korlát: jelentkezés 10/óra/IP; érdeklődés 10/óra/IP és 3/óra/e-mail. A korlátok memóriabeliek, az újrapróbálások is beleszámítanak.

## Igazolt ellenőrzések

| Ellenőrzés | Eredmény |
| --- | --- |
| TypeScript + Vite kliens/SSR/prerender | Sikeres; 18 útvonal + 404 |
| Frontend HTML/SEO tesztek | 6/6 sikeres |
| Backend mvn clean verify | 23/23 sikeres, 0 hiba, 0 kihagyás |
| Backend tesztadatbázis | Külön valódi Testcontainers MariaDB 11.4.10 |
| Migráció | V1/V2 → V3, régi rekord/ár megőrizve |
| Párhuzamos kapacitás | 30 elfogadásból pontosan 24 siker, 6 konfliktus |
| Párhuzamos ismétlés | 6 jelentkezési és 4 érdeklődési kérésből egy-egy rekord |
| Árképzés | Budapest dátumhatárok, összevonás, 35%-os plafon |
| Teljes Docker build és végleges backend újraépítés | Október 21-én sikeres, három healthy szolgáltatás |
| node scripts/smoke-test.mjs | Október 21-én sikeres Nginx → API → MariaDB útvonalon |
| Local/production Compose config | Érvényes |
| OH-hivatkozások | 20/20 ellenőrzött PDF/ZIP |
| Publikus böngészős próba | Mobilmenü, csoportválasztás, két baráttal 35%, mentett 182 000 Ft díj; érdeklődés mentése |
| Admin böngészős próba, október 22. | Belépés, csoportszűrés, megőrzött dátum/díj, jelentkezés CONTACTED; érdeklődés COMPLETED + megjegyzés frissítés után is megmarad; kilépés |
| Újraindítás utáni működés, október 22. | Mindhárom szolgáltatás healthy, API UP, web HTTP 200, csoportidők helyesek, korábbi rekordok megmaradtak |
| Reszponzív nézet | 1440/390 px, főoldal/kurzusok vízszintes kilógás nélkül |

Backend: 11 díjszámítási, 4 meglévő platformintegrációs, 8 új jelentkezési teszt. A teszt feltárt egy Windows időzónahibát: explicit JDBC LOCAL_TIME mapping biztosítja, hogy MariaDB TIME 09:00 Budapest JVM alatt is 09:00 maradjon. A jelentkezési dátum és árazás ugyanazt az egyszer rögzített Instantot használja. A végleges Docker image ezeket is tartalmazza.

A smoke a SEO/404/átirányítások mellett csoportot/szűrést, mentett árat/dátumot, idempotenciát, manuális érdeklődői státuszt, CSRF/jogosultságot, védett fájl byte-jait, usertiltást, auditot és logoutot vizsgál. Fiktív jelentkezést, érdeklődőt és letiltott tesztusert hagy; saját óráját/fájlját törli. Az október 21-i futás rekordjai: jelentkezés 4, érdeklődés 1, user 5. A böngészős próba külön fiktív jelentkezőt és érdeklődőt is mentett; nem valódi személyek.

Buildméret: kb. 92,4 KB gzip JS, 12 KB gzip CSS; két WebP összesen 128 342 byte, saját WOFF2 külön. Ez nem Lighthouse vagy valódi mobilhálózati mérés.

Képek: [új főoldal](screenshots/strategy-home-desktop.jpg), [új mobil főoldal](screenshots/strategy-home-mobile.jpg), [mobil kurzuskártyák](screenshots/strategy-courses-mobile.jpg), [admin csoportszűrés](screenshots/strategy-admin-applications.jpg), [kézi érdeklődőkezelés](screenshots/strategy-admin-interests.jpg). Az október 17-i képek történeti állapotot mutatnak. Az adminpróba során nem jelent meg böngészőkonzol-hiba vagy figyelmeztetés.

## Üzemeltetés és fennmaradó határok

Az aktuális telepítési állapot a fenti október 24-i szakaszban és a [DEPLOY-STATUS](DEPLOY-STATUS.md) fájlban van. Valódi CI, VPS-deploy, belső auth, izolált backup/restore és mindkét alkalmazás automatikus frissítése sikeres; a restore üres uploadarchívummal történt. Publikus HTTPS, külső mentés és napi naptári backup-futás ettől külön követendő. A korábbi dátumozott eredmények történeti ellenőrzések. Backend/frontend kompatibilis kiadást igényel; üzemeltetéshez [DEPLOYMENT](DEPLOYMENT.md).

Hosszú állás után a helyi Docker Desktop két alkalommal elakadt. Október 21-én és 22-én az újraindítás helyreállította, volume-t nem töröltünk. A második alkalommal a célzott `wsl --terminate docker-desktop` néhány perc alatt fejeződött be, utána Docker Desktop indítás és `docker compose up -d --wait db backend frontend` segített. WSLService-újraindítás jogosultság híján nem történt; teljes WSL shutdown vagy adattörlés sem. Ez környezeti hiba; a következő munka elején Docker állapot és API health ellenőrzés szükséges. A másik projekt DB-je is healthy állapotban maradt a helyreállítás után.

A tananyagok közösek minden aktív diáknak: jelentkezési csoport még nem tananyag-tagság. Nincs automatikus beiratkozás, barát-összepárosítás, fizetés, jelszó-visszaállító meghívó, MFA vagy marketing CMS. Adminlisták nem lapozottak, napló 200 esemény. Session memóriabeli; backend restart után új belépés kell.

Véglegesítendő: portrék, terem/telefon, laptopbérlés, fizetési/lemondási feltételek, jogi szövegek/adatmegőrzés, kóstolóanyag, 20 alkalom pontos naptára. Húsz egymást követő szombat január 9-től május 22-ig tart, ezért a vizsgához igazítás szervezői egyeztetést igényel.

A production VITE_APPLICATIONS_ENABLED csak UI-kapcsoló: az API ettől külön fogad CSRF-védett kérést. Éles adatgyűjtés előtt végleges tájékoztatás és adatkezelési folyamat szükséges. Az alkalmazás már a VPS-re is telepítve van, a publikus domain aktiválását a felhasználó későbbre halasztotta.

## Következő agent

1. Érintett repó AGENTS/README, ez az átadás és STRATEGY/ARCHITECTURE/DECISIONS.
2. API-hoz backend/API.md; tartalomhoz PRODUCT/SEO/IMAGE-ASSETS; telepítéshez SECURITY/DEPLOYMENT.
3. Git státusz mindhárom repóban, Docker állapot; volume-ok és meglévő munka megőrzése.
4. Fókuszált változás, megfelelő ellenőrzés, dokumentációfrissítés. Alkalmazott V1/V2/V3 helyett új migráció.
