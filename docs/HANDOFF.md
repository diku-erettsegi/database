# Átadás – 2026. november 6.

## Tantermi digitális kultúra felkészítő SEO – 2026-11-06

A felhasználó több természetes előfordulást kért a „tantermi digitális kultúra felkészítő” kifejezésből. Főoldal: új H1 („Tantermi digitális kultúra felkészítő Budapesten.”), bemutatkozó és záró kurzusajánló szöveg, összesen 3 előfordulás a main tartalmában; negyedik a közös láblécben. Az emelt érettségi továbbra is látható az eyebrow/bevezetőben. Kapcsolódó kurzus/jelentkezés, árak, oktatásmenet, helyszín, GYIK és szülői/diák oldalak rövid szövege és saját metaadata pontosítva. OG és kezdőlapi JSON-LD leírás a közös seo.ts-ből követi. Nincs új útvonal, séma, függőség, API- vagy űrlapkapcsoló-változás; stock-alt, canonical és noindex szerződés megmaradt. Irány: [SEO](SEO.md).

Helyi ellenőrzés: `npm run build` (típusok, kliens/SSR, 18 oldal + 404), `npm test` 9/9 PASS. Meglévő Vite preview 127.0.0.1:4173: főoldal asztali, 390 és 320 px beállított viewportban kifér, nincs konzolhiba. Új tesztjelentkezés vagy adatváltoztatás nem történt. Bizonyítékok Gitből kizárva: `.deploy/seo-home-desktop-20261106.png`, `.deploy/seo-home-mobile-20261106.png`.

**Éles kiadás igazolt:** frontend `b72834f4b33361995027a52619e891cd8e91330b`, [CI 42135530930](https://github.com/diku-erettsegi/frontend/actions/runs/42135530930) success. A meglévő VPS-timer automatikusan telepítette; kézi deploy vagy timerleállítás nem történt. 2026-11-06 00:19:42 UTC / 01:19:42 Budapest: deploy success/0, négy healthy konténer, két enabled/active timer, nincs pending/recovery jelző. Frontend digest `sha256:b69f314e51d4159406c2828b056d68c5359fdc139323caaa7342eea199fbc4bf`, egyezik a GHCR main és commit taggel. Backend image változatlan; a szokásos mentési/telepítési folyamat újraindította. Telepítés közben rövid 502 válasz volt, a záró ellenőrzésben megszűnt.

Kilenc érintett publikus HTTPS-oldal 200/DYNAMIC, egy H1, egyedi title/description, megfelelő canonical, OG-egyezés és helyi builddel egyező metaadat. A főoldal éles böngészőben is ellenőrizve, konzolhiba nélkül. Nem végeztünk éles adatbeküldést, backendtesztet/API-smoke-ot nem ismételtünk szövegváltozás miatt. A jelentkezés és jogi tervezet állapota változatlan. Bizonyítékok: `.deploy/seo-live-verification-20261106.json`, `.deploy/seo-vps-audit-20261106.log`, `.deploy/seo-home-live-20261106.png`. Részletes kiadás: [DEPLOY-STATUS](DEPLOY-STATUS.md).

A régi TEMP/diku-ssh-libs csomagból hiányzott a paramiko init fájl; külön Gitből kizárt `.deploy/ssh-libs-20261106` függőségkészlet és `.deploy/ssh-run-20261106.py` helper készült. Ugyanazt a korábban rögzített SSH-hostkulcsot ellenőrzi; hitelesítő adat nem került kimenetbe vagy Gitbe. Ez helyi ellenőrzési segéd, nem szerverkonfiguráció-változás.

---

## Novemberi üzleti adatok, jelentkezéskezelés és éles kiadás

A felhasználói kérdőív és az utána kapott pontosítások feldolgozva. A nyers `Downloads/message.txt` nincs a repóban; a jóváhagyott tények és hiányok: [LAUNCH-ANSWERS-2026-11](LAUNCH-ANSWERS-2026-11.md). A három repó külön marad. Titkok továbbra is csak kizárt helyi fájlokban.

**Éles alkalmazás:** frontend `acf82a5d701bbd00c7cc941faed7458ff2acfd5b`, backend `39ebf8dcc16e4591d08082950540f6b063a0a36d`. Mindkét main CI success; 2026-11-03 22:38:51 UTC / 23:38:51 Budapest sikeres összehangolt telepítés, V4 migrációval. Négy healthy konténer, deploy és backup timer enabled/active; 22:42:34 UTC záró audit success/0, nincs pending vagy recovery-required jelző. A deploy timert a két image elkészüléséig átmenetileg megállítottuk, majd visszakapcsoltuk és a szokásos deploy service-t kézzel indítottuk; nem két külön, véletlenszerű részkiadás történt. Részletes digestek és ellenőrzés: [DEPLOY-STATUS](DEPLOY-STATUS.md).

### Megvalósított működés

- Céges/impresszumadatok, konkrét helyszín és érkezés, kapcsolattartás, min. 14 év, 15–24 fős induló csoport, fizetési feltételek. Ismeretlen telefon/terem/tematika/portré és jogi szöveg nincs kitalálva.
- Laptopbérlés **30 000 Ft a teljes képzésre**, külön a képzési díjtól. Az új jelentkezés menti a laptopdíjat; réginél ismeretlen marad. A kedvezmény nem csökkenti a laptopdíjat.
- Korai kedvezményhez **teljes képzési befizetés** kell november 15-ig / december 15-ig. A korai és igazolt baráti rész maximum 35%. Az eredeti feltételes ajánlat változatlan; külön admin pénzügyi összesítő őrzi a szerződésigazolást, képzésre befizetett összeget, teljes befizetés napját és az igazolt baráti kapcsolatok számát. Nincs automatikus bank/számlázó integráció; a laptopbefizetés nem része ennek az összesítőnek.
- Kiskorú jelentkezéshez szülő neve és eljárási nyilatkozat, szerveroldali validációval. 5 fős várólista explicit választással, csoportsorzárral. Elfogadáshoz szerződésigazolás és pozitív befizetés kell. A nyilvános jelentkezési határidő 2027-01-23; később egyedi szervezői folyamat, nem új admin-beküldési végpont.
- Admin csoportváltás szabad helyre vagy elfogadott jelentkezések atomikus cseréje. Naptár szerkeszthető, 20 egyedi növekvő dátummal.
- Jóváhagyott naptár: **2027-01-09–2027-05-29**, május 15. kimarad; május 22. és 29. szóbeli felkészítés. Ezeket ne kérdezd újra. A naptár `course_dates` adatokból áll, nem generált húsz tananyagóra.
- Tanulói fiók egy elfogadott jelentkezéshez köthető. Csak a saját csoport közzétett órái/fájljai érhetők el, a kurzus végét követő egy hónapig (**2027-06-29 nap végéig, Budapest**). A közvetlen letöltési URL is ellenőrzött. Csoport nélküli régi óra nem látható diáknak; adminnak csoporthoz kell rendelnie. A jogosultság lejárata nem adattörlés.

### Ellenőrzések

- Backend `mvn verify`: **29/29 PASS**, valódi Testcontainers MariaDB 11.4, 0 kihagyott teszt. Ide tartozik párhuzamos várólista (12 kérésből pontosan 5 hely), kiskorú/szülő, laptopdíj, határidős teljes befizetés, változatlan ár, idempotencia, helycsere, csoporton kívüli fájlletöltés tiltása és lejárat.
- Frontend build: TypeScript, kliens/SSR, **18 előrenderelt útvonal + 404, 9/9 teszt PASS**. Main CI-ben a valódi Nginx proxyteszt is success. A helyi Docker működik (29.4.3), az októberi 500 hiba nem aktuális akadály.
- Teljes helyi Compose healthy; frissített `scripts/smoke-test.mjs` PASS: SEO, CSRF/admin, jelentkezés→pénzügy→elfogadás→tanuló→csoportóra→privát fájl byte-egyezés, másik csoport 404, session érvénytelenítés és letiltás.
- Helyi böngésző: kiskorú+szülő+laptop, két baráttal 35% / 182 000 + 30 000 Ft, pénzügy mentése, elfogadás, naptár mentése. A React szomszédos admin komponensek azonos kulcsa miatt megmaradó régi form javítva, újraellenőrizve: kiválasztás megszüntetése után nincs ottmaradó űrlap, Naptár lapon csak két kurzusűrlap.
- Mobil 390 px árak/jelentkezés: nincs vízszintes kilógás. Éles böngészőben új képzési időpontok, teljes befizetés feltétele, két kurzusár és nyitható húszalkalmas naptár; nincs konzolhiba/kilógás. Publikus HTTPS nyolc oldalon 200/DYNAMIC, egyedi title, egy H1, helyes canonical. Éles `/api/courses` két húsznapos naptárt, május 29-i végét és január 23-i jelentkezési határidőt ad. Mindkét futó digest egyezik a main és commit SHA tagekkel.
- Az éles adatbázisban a kiadáskor 0 jelentkezés, 0 tanulói fiók, 0 óra/fájl volt. Éles tesztjelentkezést vagy felhasználót nem hoztunk létre; a módosító folyamatokat helyben teszteltük. A telepítés előtti mentés COMPLETE, DB 13 116 bájt, uploadarchívum 109 bájt. Új restore-próba most nem történt.

### Helyi tesztadatok és bizonyítékok

A smoke fiktív jelentkezése **6** (REJECTED), érdeklődője **3**, tesztusere **6** (letiltva); a saját tesztóra/fájl törölve. A böngészős fiktív jelentkezés **7** pénzügyi ellenőrzése megmaradt, státusza végül CONTACTED, nem foglal elfogadott helyet. Más adatot nem töröltünk. Ezek csak helyi adatok.

Gitből kizárt nyomok: `.deploy/launch-backend-verify.log`, `.deploy/launch-live-deploy-20261103.log`, `.deploy/launch-final-audit-20261103.log`, `.deploy/launch-live-verification-20261103.json`, `.deploy/launch-pricing-mobile-20261103.png`, `.deploy/launch-courses-live-20261103.png`; backend `target/surefire-reports`. A publikus HTTP-ellenőrzés a Python alap User-Agentre Cloudflare 1010 választ kapott, az azonosított DIKU release-ellenőrző User-Agenttel és rendes böngészőből sikeres; Cloudflare-védelmet nem kapcsoltunk ki.

### Következő konkrét lépés

A felhasználó **külön, átnézendő adatkezelési tervezetet kért**: [ADATKEZELESI-TAJEKOZTATO-TERVEZET](ADATKEZELESI-TAJEKOZTATO-TERVEZET.md), megnyitva a szerkesztőben. Célonkénti adatkör/jogalap-javaslat, megőrzési javaslat, törlésfelelős, felvételek alternatívája, szolgáltatók/átadások, joggyakorlás és konkrét jóváhagyási lap szerepel benne. **Nem jóváhagyott végleges jogi szöveg**, nem került a publikus adatkezelési oldalra. A javaslatok elfogadása után a hiányzó törlési/nyilatkozati folyamatot is meg kell valósítani, és a backend draft privacyVersion értékeit végleges verzióra váltani.

A production `APPLICATIONS_ENABLED` változatlanul false: a felület előkészítési jelzést és tiltott beküldést mutat. Ez csak felületi kapcsoló, nem szerveroldali API-zár. A tervezet elkészítését és a működő új admint ne keverd össze az élő jelentkezés megnyitásával. Nincs SMTP, automatikus levél, e-mailes jelszó-visszaállítás, offsite mentés vagy operátori e-mailriasztás. A felvételek jogalapja/nyilatkozata, megőrzési szabályok, szolgáltatói szerződéses adatok és szerződési feltételek továbbra is véglegesítendők; részletek a novemberi listában. A 20 MB feltöltési korlát nem teljes órai videóplatform.

---

## Korábbi átadás – 2026. október 27. (történeti állapot)

## Egységes kedvezményes ármegjelenítés – október 27.

A frontend `src/PriceDisplay.tsx` és `src/price-display.css` közös árblokkja az Árak oldal mellett a `/kurzusok`, `/jelentkezes`, élő űrlapösszesítő, beküldési visszajelzés és admin jelentkezésrészlet nézetében is használatos. Nagy piros díj, áthúzott alapár, százalék és tényleges megtakarítás; a kurzuskártyán az ár a részletes adatok elé került. Az admin táblázatos lista tömör marad. Megjelenítés, API és üzleti díjszabály szétválasztva: a komponens nem áraz újra mentett rekordot, kedvezmény nélkül nem mutat hamis áthúzást/megtakarítást. A publikus receipt API nem ad alapdíjat, ezért abban a nézetben csak a kapott végösszeget/tanóradíjat/százalékot emeljük ki. Nincs backend-, séma-, űrlapengedélyezési vagy levelezési módosítás.

Helyben igazolt: TypeScript + kliens/SSR build, 18 oldal + 404; 9/9 teszt (6 SEO, 3 megjelenítési regresszió: tényleges megtakarítás, teljes ár, történeti/hiányos alapár). Valódi helyi API-val 0/1/2/10 barát esetén 210/196/182/182 ezer Ft, a 35%-os maximum megmarad. Két csoport választása; kurzus/űrlap 390 és 320 px, Árak 820 és 320 px, asztali megjelenítés kilógás nélkül; nincs böngészőkonzol-hiba. Jelentkezést nem küldtünk be, admin belépést nem teszteltünk újra. A helyi Vite preview PID 24464 tovább fut, helyes előrenderelt útvonalak záró perjellel: `http://127.0.0.1:4173/kurzusok/`, `/jelentkezes/`, `/arak/`.

**Éles frissítés igazolt:** frontend `25991faf5492cd695fe0253d4bd47eec761ebc27`, [CI 40537834858](https://github.com/diku-erettsegi/frontend/actions/runs/40537834858) success, saját VPS-timerrel automatikus frissítés. 16:10:33 UTC: service success/0, négy healthy konténer, két active timer. Frontend digest `sha256:84261a365ed28747a7838d0cfd1014a49f952f977e467ca7cb84d651f7c48ef9`; `/arak`, `/kurzusok`, `/jelentkezes` HTTPS 200/DYNAMIC, új `index-CgSKCACW.css`, egy H1 és helyes canonical. Éles böngészőben mindkét kurzus közös piros árblokkja, 210 000 Ft / −25% / 70 000 Ft megtakarítás, konzolhiba és kilógás nélkül. Részletek: [DEPLOY-STATUS](DEPLOY-STATUS.md). A publikus űrlap engedélyezése külön, változatlan előkészítési állapot; ne állítsd e megjelenítési frissítés alapján, hogy a jelentkezés megnyílt. Bizonyítékok: `.deploy/shared-pricing-live-verification-20261027.json`, `.deploy/shared-pricing-live-20261027.png` (Gitből kizárva).

## Árak oldal: kedvezmények előtérben – október 26.

A frontend `/arak` oldalán a kedvezményes ajánlatok kerültek felülre: piros −25%, áthúzott 280 000 Ft, nagy 210 000 Ft és 70 000 Ft megtakarítás; mellette az akár −35% / 182 000 Ft / 98 000 Ft megtakarítás, közvetlenül feltüntetett november 15-i és két hozott barát feltétellel. A 15%-os ajánlat külön sávban, november 16. – december 15. dátummal szerepel. Alapdíj, képzéstartalom, baráti táblák és feltételek lejjebb; díjszámítás/API nem változott. A JSX a frontend `src/App.tsx` Pricing függvényében, a kiegészítő stílus `src/pricing.css` fájlban van. Statikus dátumok és SEO-előrenderelés megmaradtak.

Igazolt: frontend build és 6/6 SEO-teszt; asztali/820/390/320 px elrendezés, oldalszintű/kártyán belüli vízszintes kilógás nélkül; kedvezményrészletek horgony és kurzus CTA működik. A kész build Vite preview alatt `http://127.0.0.1:4173/arak/` címen látható (indított helyi Node folyamat PID 24464). A záró perjel nélküli Vite preview SPA-fallback téves kezdőlapi HTML-je külön hidratálási hibát adhat; a helyes `/arak/` betöltésekor nincs új konzolhiba. A helyi Docker Engine `compose ps` lekérdezése 500 hibát adott, ezért nem állítottuk újra a Dockert és nem módosítottuk a helyi konténereket/volume-okat.

**Éles frissítés kész:** frontend `bad7369a6368e7f2ba55f81e794f5a63e2655e4a` main push, [CI 40294972010](https://github.com/diku-erettsegi/frontend/actions/runs/40294972010) success, automatikus VPS-frissítés. 08:53 UTC-kor a deploy service success/0, négy healthy konténer, két aktív timer; frontend digest `sha256:f71b8a04f3be5681e489d1bdd187776da7d086abca2d1235cc7f0d3e6811e76f`. A publikus `https://diku-erettsegi.hu/arak` HTTP 200, új ajánlatok és CSS, egy H1 és helyes canonical; böngészőben az új oldal, új konzolhiba nélkül. A frissítés közben rövid 502 választ láttunk, az ellenőrzés végére megszűnt. Helyi bizonyítékok a Gitből kizárt `.deploy/pricing-live-verification-20261026.json`, `.deploy/pricing-live-20261026.png`, `.deploy/pricing-mobile-20261026.png` fájlokban. Publikus belépési/POST próbát most nem végeztünk; részletek: [DEPLOY-STATUS](DEPLOY-STATUS.md).

## DKIM és DMARC beállítva – október 25., 22:42 CET

A felhasználó a Gitből kizárt `secrets/dkim-record.txt` fájlban átadta a nyilvános DKIM-kulcsot, majd képernyőképpel igazolta a `default._domainkey` nevet és a `_dmarc` rekord `v=DMARC1;p=none` értékét. Mindkét TXT-rekordot felvettük Cloudflare-ben, DNS only, a kapott 3600 másodperces TTL-lel. A felület nyolc DNS-rekordot mutat, mindkét új rekord visszaolvasva. A DKIM-kulcs érvényes, 2048 bites RSA; DER SHA-256: `30852beef4b55462d436afa33218d92dfb22fb812fff48e7a77d937776fcd9e6`. Nem generáltunk új kulcsot, privát kulcsot nem kezeltünk.

Mindkét autoritatív Cloudflare-névszerver visszaadja a két TXT-rekordot. A Google és Cloudflare DoH DKIM-válasza teljes tartalmában egyezik a kapott értékkel (a DNS TXT-darabok összefűzése után); Cloudflare DoH-n DMARC is egyezik. A Google DMARC-lekérdezése 21:42:44 UTC-kor még korábbi NODATA választ ad, 1494 másodperc hátralévő negatív cache TTL-lel; ez terjedési korlát, nem hiányzó autoritatív rekord. Ne állítsd, hogy már minden resolver frissült. MX `5 mail.diku-erettsegi.hu`, mail A `185.111.89.212` és SPF `v=spf1 ip4:185.111.89.212 ~all` változatlan, mindkét publikus resolverrel igazolt.

Helyi, Gitből kizárt ellenőrzési nyomok: `.deploy/dkim-verification-20261025.json`, `.deploy/dkim-authoritative-20261025.json`, `.deploy/dmarc-google-recheck-20261025.json`, `.deploy/cloudflare-dkim-dmarc-20261025.png`. Beállítások és folytatás: [CLOUDFLARE-SETUP](CLOUDFLARE-SETUP.md). A `p=none` nem kér karantént vagy elutasítást; nincs `rua` riportcím. Valódi levélküldési/fogadási próba és `Authentication-Results` fejlécellenőrzés még nincs; a DNS-beállítás önmagában nem bizonyítja a küldőszerver aláírását. Webes Tunnel, alkalmazáskód, VPS és automatikus levélküldés nem változott. A kitöltött kulcsfájlt ne másold Gitbe.

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
