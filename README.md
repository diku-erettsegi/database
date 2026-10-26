# DIKU – adatbázis és üzemeltetés

**Legfrissebb éles ellenőrzés (2026-10-26):** az átdolgozott Árak oldal sikeres main push/CI után automatikusan frissült a VPS-en. A publikus `https://diku-erettsegi.hu/arak` HTTPS-en HTTP 200, az új árkártyák és CSS ellenőrzöttek; négy healthy konténer, két aktív timer. Ez felülírja az alábbi történeti halasztási/pending állapotot. DKIM és DMARC is felvéve; a levelek tényleges aláírása külön ellenőrzést igényel. Pontos eredmények: [DEPLOY-STATUS](docs/DEPLOY-STATUS.md), [Cloudflare és levelezés](docs/CLOUDFLARE-SETUP.md).

**Aktuális telepítési állapot (2026-10-24): [DEPLOY-STATUS](docs/DEPLOY-STATUS.md).** A VPS-deploy, belső admin-auth és izolált restore sikeres. Mindkét timer enabled/active; frontend és backend main push → CI → GHCR → timer → VPS frissítés PASS, az adatok megmaradtak. A backup systemd service kézi próbája és a napi naptári ütemezés külön igazolt; négy healthy konténer, bootstrap eltávolítva. A restore üres uploadarchívummal történt, valódi tananyagbyte-próba még nincs. Cloudflare route/DNS, www 301 és privát/API cache bypass beállítva; a Microware névszerverváltást és a publikus HTTPS-próbát a felhasználó későbbre halasztotta. A korábbi előkészítési állapotot az alábbi dátumozott leírás őrzi.

A `diku-erettsegi.hu` React + Spring Boot + MariaDB alkalmazása. Ez a repó tartalmazza a helyi és Ubuntu VPS környezet Compose konfigurációját, az üzemeltetési scripteket és a közös dokumentációt.

## Jelenlegi funkciók – 2026. október 21.

- 18 előrenderelt útvonal és külön 404 oldal, egyedi SEO-metaadatokkal, mobil navigációval és helyi stockfotókkal. Kurzusok, szülői/diák tájékoztatók, oktatók, árak, helyszín és hivatalos OH-feladatsorok.
- Két szombati csoport, legfeljebb 24 elfogadott jelentkezéssel csoportonként. A jelentkezés rögzíti a csoportot, beküldési időpontot, baráti ajánlást és laptopigényt; hálózati újrapróbáláskor azonos kérés nem duplikálódik.
- Szerver által számított és megőrzött árajánlat: a korai és baráti kedvezmény összeadódik, maximum 35%-ig. A baráti jogosultságot a szervezők kézzel ellenőrzik.
- Admin jelentkezési lista csoport-/státuszszűréssel, létszámmal és mentett árakkal. Külön programozós érdeklődői lista, kézzel szerkeszthető státusszal és belső megjegyzéssel. Az alkalmazás nem küld automatikus e-mailt.
- Session/CSRF belépés, admin felhasználókezelés és audit; órák, dátumok, értekezletlinkek, privát fájlfeltöltés és tanulói letöltés. A tananyagok egyelőre közösek minden aktív diáknak.

A képzés adatai és a hátralévő tartalmi döntések a [stratégiában](docs/STRATEGY-2026-10.md) követhetők. Éles publikálás még nem történt.

## Helyi indítás

A három klón egymás mellett legyen: `frontend/`, `backend/`, `database/`. Docker Desktop Linux konténerekkel (Windows), vagy Docker Engine + Compose plugin (Linux) szükséges.

```powershell
cd database
docker compose up -d --build --wait
```

- Weboldal: http://localhost:8088
- Backend health: http://localhost:8080/actuator/health
- MariaDB: `127.0.0.1:3308`, adatbázis/felhasználó `diku`, jelszó `diku_local_password`
- Admin: `admin@diku.local` / `DikuAdmin2026!`
- Diák: `diak@diku.local` / `DikuDiak2026!`

Ezek kizárólag a `local` profil tesztadatai; az éles profil nem hozza létre őket. A jelentkezések, programozós érdeklődések, felhasználók és órák valódi MariaDB-adatok. A fájlok külön Docker volume-ba kerülnek. Egy jelentkezés önmagában nem készít felhasználót: az admin külön hoz létre tanulói fiókot.

Az opcionális `.env` fájl a `.env.example` másolásával készíthető el, például portütközés esetén. Az alkalmazás csak a saját gépről érhető el. Indítás után az adminban hozhatók létre az órák és tölthetők fel fájlok.

Teljes helyi integrációs próba Node22+ alatt, ebből a mappából:

```powershell
node scripts/smoke-test.mjs
```

A próba **fiktív jelentkezést, programozási érdeklődőt és letiltott tesztdiákot hagy** az adatbázisban, megtekintéshez. Sikeres végigfutáskor a saját tesztóráját és fájlját törli; más órát vagy feltöltést nem töröl. Csak localhost/127.0.0.1 címmel futtatható. Helyben fiktív személyes adatokat használjunk.

Az aktuális ellenőrzési körben **23/23 backendteszt sikeres valódi MariaDB-n**, és **6/6 frontendteszt sikeres**. A teljes környezet, böngészős próbák és korlátok részletes állapota a [HANDOFF](docs/HANDOFF.md) fájlban található.

```powershell
docker compose ps
docker compose logs --tail 100 backend
docker compose down
```

A `down` megőrzi az adatokat. A `down -v` **végleg törli a helyi adatbázist és feltöltéseket**; normál leállításhoz ne használd.

## Fejlesztés

Frontend gyors újratöltéssel: `frontend` mappában `npm ci`, majd `npm run dev`. A Vite az API-kéréseket a `localhost:8080` backendhez továbbítja. A backend és DB eközben futhat a fenti Docker környezetből. Java fejlesztési mód és API leírás: [backend README](../backend/README.md), [API](../backend/API.md).

A Flyway SQL migrációk egyetlen hiteles forrása a backend `src/main/resources/db/migration` mappája. Ebben a repóban ne készíts másolatot vagy párhuzamos inicializáló SQL-t. MariaDB automatikusan elkészíti az üres adatbázist; a sémát az induló backend migrálja.

A V1–V3 migráció megőrzi a régi jelentkezéseket és mentett árakat. A V2 történeti `mail_outbox` táblája használaton kívül marad; nincs SMTP-függőség, háttérküldő vagy Mailpit szolgáltatás. A programozós érdeklődőkkel a szervezők saját levelezőjükből veszik fel a kapcsolatot.

## Dokumentáció és következő fejlesztők

- [Architektúra](docs/ARCHITECTURE.md), [döntések](docs/DECISIONS.md)
- [Termék, oldalak, tartalmi helyek](docs/PRODUCT.md), [SEO](docs/SEO.md)
- [Aktuális stratégia és képzési adatok](docs/STRATEGY-2026-10.md), [stockfotók és forrásaik](docs/IMAGE-ASSETS.md)
- [Biztonság](docs/SECURITY.md), [fejlesztési ütemterv](docs/ROADMAP.md)
- [VPS telepítés](docs/DEPLOYMENT.md), [Cloudflare és domain](docs/CLOUDFLARE-SETUP.md), [szerverfelmérés](docs/SERVER-AUDIT-2026-10-22.md)
- [Átadás és ellenőrzések](docs/HANDOFF.md)
- [Agent útmutató](AGENTS.md)

## Automatikus telepítés előkészítése – 2026. október 22.

A frontend/backend main push után a GitHub Actions tesztel, image-et készít és publikál a GHCR-be. A VPS systemd timere kétpercenként ellenőrzi az image-eket; változáskor mentést készít, digest alapján frissít és healthchecket vár. A Cloudflare Tunnel a belső `frontend:80` szolgáltatást teszi elérhetővé. A szerveren nincs nyitott alkalmazás- vagy adatbázisport.

A production Compose, a titkokat nem naplózó preflight, backup/deploy scriptek és kétperces deploy/napi backup systemd minták elkészültek. A deploy csak egészséges kiadást rögzít, hibás párt elkülönít és megszakadt frissítésből helyreáll; a visszaállítás hibája blokkolja az újabb automatikus próbát. MariaDB/cloudflared digest rögzített, a Tunnel tokent külön fájl-secret adja át. A napi mentés hibánál korlátozottan újrapróbálkozik; külső mentési cél és riasztás még nincs bekötve.

A Rackforest VPS SSH-felmérése sikerült: Ubuntu 24.04, 1 vCPU / 4 GB RAM, Docker még nincs telepítve. Szervermódosítás, GitHub push és éles aktiválás nem történt. A domain maradhat a magyar regisztrátornál; a Cloudflare DNS-átállítás a meglévő levelezési rekordok megőrzésével készül. A [telepítési útmutató](docs/DEPLOYMENT.md) tartalmazza az első indítás és visszaállítás menetét; a registry image-ek az első sikeres main CI után lesznek elérhetők.
