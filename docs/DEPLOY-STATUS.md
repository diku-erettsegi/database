# Telepítési állapot – 2026-10-25

## Legfrissebb: a névszerverváltás megtörtént, Cloudflare-aktiválás függőben

A felhasználó október 25-én jelezte a DNS átírását és ellenőrzést kért. A 12:27 Europe/Budapest (CET) időpontban indított vizsgálat **igazolja a regisztrátori névszerverváltást**, de még nem a nyilvános weboldal működését. Ez felülírja az alábbi október 24-i halasztást.

- A `.hu` szülőzónát kiszolgáló `a.hu` közvetlen, nem rekurzív válasza kizárólag `alexa.ns.cloudflare.com` és `gerardo.ns.cloudflare.com` delegálást ad. Google és Cloudflare DNS-over-HTTPS NS-lekérdezés ugyanezt igazolja.
- A szülőzónában DS rekord nincs; a két publikus resolver sem ad DS-t. Régi DS miatti DNSSEC-validációs hibát nem találtunk; DNSSEC-et nem kapcsoltunk be.
- A Cloudflare felületen továbbra is **Pending Nameserver Update / Waiting for your registrar to propagate your new nameservers**. A **Check nameservers now** kérés sikeresen elküldve; a felület visszajelzése szerint az ellenőrzés elindult. Ez nem aktiválási siker.
- A Cloudflare DNS-táblában az apex továbbra is a helyes Tunnelre mutat, Proxied; www CNAME az apexre, Proxied. A mail A és MX megőrizve, a publikus resolverekből is visszaolvasható. DNS-rekordot, névszervert, proxykapcsolót vagy Tunnel-beállítást nem módosítottunk.
- Az ellenőrzéskor a két autoritatív Cloudflare-névszerver nem ad publikus apex A címet; az AAAA-válasz `fd10:aec2:5dae::`. A Google A cache még a régi tárhelyet mutatta. A helyi gépről a HTTP/HTTPS névfeloldás hibás, a VPS-ről a HTTPS-kapcsolat sikertelen. Főoldal/API/belépés/www nyilvános működését ezért még nem igazoltuk, tanúsítványellenőrzést nem kerültünk meg.
- SSH-n a VPS négy production konténere healthy. Ez a vizsgálat nem indított deployt, mentést vagy alkalmazásbeli tesztadatot.

A [Cloudflare leírása](https://developers.cloudflare.com/dns/zone-setups/reference/domain-status/#pending) szerint a pending zóna már adhat DNS-választ, de még nem proxyzza a webforgalmat. Következő ellenőrzés: zóna Active, publikus A/AAAA és érvényes HTTPS, majd apex/www átirányítás, API/cache és belépés. **A Microware névszerverváltást nem kell megismételni.** Ezt a feladatot ellenőrzésként lezártuk; nincs külön időzített Codex-monitor.

## Október 24-i telepítési ellenőrzések (történeti állapot)

A felhasználó kifejezetten kérte a tényleges deploy folytatását. Ez a fájl az aktuális, ellenőrzött állapot; az október 22-i szerverfelmérés és a korábbi előkészítési bejegyzések történeti pillanatképek. A telepítési útmutató eljárásleírás, önmagában nem igazolja az ott szereplő lépések végrehajtását.

**A VPS-deploy, belső admin-auth, izolált backup/restore, mindkét alkalmazás automatikus main → VPS frissítése és a backup systemd szolgáltatás külön próbája sikeres. A végső ellenőrzéskor négy healthy konténer és két enabled/active timer; az adatok megmaradtak. A Microware névszerverváltást és a publikus HTTPS-próbát a felhasználó későbbre halasztotta; most kihagyjuk.**

## Végrehajtva

- SSH-hozzáférés újra ellenőrizve, a korábban rögzített hostkey megőrzésével.
- Ubuntu 24.04 VPS: Docker Engine 29.9.2 és Compose v5.6.1 telepítve a Docker hivatalos apt-tárolójából; Docker indul rendszerindításkor.
- `diku-deploy` jelszavas belépés nélküli felhasználó, Docker-csoporttagság, `/opt/diku` saját könyvtár. Az SSH és a tűzfal konfigurációját nem módosítottuk.
- Mindhárom repó első main pushja megtörtént, mindhárom GitHub Actions CI sikeres. A frontend és backend image-eket a felhasználó nyilvánossá tette; a VPS `diku-deploy` felhasználójával mindkét image névtelen pullja sikeres.
- A feltöltés előtt a staged fájlokat a tényleges SSH-titokra/címre és credential mintákra ellenőriztük; találat nem volt. Titok nem került Gitbe.
- Az infrastruktúra-repó klónozva a VPS `/opt/diku/database` könyvtárába. A production környezeti fájl titkos értékei privátan generálva; tartalmuk nem kerül dokumentációba vagy Gitbe.
- A deploy és backup systemd service/timer unitok telepítve; a `systemd-analyze verify` sikeres. Október 24-én **17:37 Europe/Budapest** időpontban mindkét timer `enable --now` aktiválása megtörtént; **enabled/active** állapotuk ellenőrzött.
- A felhasználó létrehozta a `diku-erettsegi` nevű, távolról kezelt Cloudflare Tunnelt, és védett fájlban átadta a tokent. A connector a Compose file-secretből olvas; a token nem környezeti változóban szerepel.
- A production preflight **a valódi VPS-en, a production konfigurációval sikeres**. A `cloudflared` connector fut és **healthy**. A nyilvános DNS/HTTPS-útvonal külön ellenőrzést igényel.

### Október 24-i állapotellenőrzés

- Az első SSH-ellenőrzéskor a `diku-db-1` és `diku-cloudflared-1` körülbelül 15 órája futott healthy állapotban. Ezt követően az első **teljes deploy is sikeresen lefutott**, mind a négy konténer healthy; az első image-párt `.release.env` rögzítette. A későbbi automatikus frissítések állapota alább szerepel.
- A `diku-erettsegi.hu` Cloudflare Free zónája létrejött; állapota **Pending Nameserver Update**. A Cloudflare által kiosztott névszerverek: `alexa.ns.cloudflare.com` és `gerardo.ns.cloudflare.com`. Ezek a beállítandó új névszerverek; a regisztrátori váltás még nincs igazolva.
- A kezdetben importált négy rekordból az apex és www korábbi A rekordját felváltotta az új webes cél: az apex proxizott CNAME a Tunnelre, a www proxizott CNAME az apexre mutat. A Tunnel `diku-erettsegi.hu` → `http://frontend:80` publikus route-ja mentve.
- A Cloudflare www → apex **301 szabálya mentve**, útvonal és query string megőrzésével. Az **Always Use HTTPS bekapcsolva**, a minimum TLS-verzió **1.2**. A pending névszerverállapot miatt még nincs kiadott edge tanúsítvány; külső HTTPS-próba nem futott. A szabály mentése nem helyettesíti a későbbi publikus ellenőrzést.
- A **DIKU private and API bypass** Cloudflare cache rule **Active** állapotban mentve: `/api`, `/admin`, `/tanulo`, `/belepes` útvonalprefix vagy `JSESSIONID` cookie esetén **Bypass cache**. Külső működési ellenőrzése a domainváltás után következik.
- A wildcard A és a hozzáadott külön `mail` A **DNS only**, az MX prioritás `5`, cél `mail.diku-erettsegi.hu` megőrizve. A rekordok állapota a Cloudflare felületén visszaolvasva. Ez a konfigurációt igazolja, a névszerverváltás megtörténtét nem.
- A felhasználó megerősítette: a domain regisztrátora **Microware**, jelenleg nincs használt domainhez tartozó levelezés vagy aldomain; a későbbi levelezést maga intézi. A meglévő mail/MX/wildcard rekordokat megőriztük. Legfrissebb utasítása szerint a két névszervert később váltja át, ezért a névszerverváltás most **kihagyandó**, az esetleges korábbi átállításra utaló közlés nem aktuális.

### Első sikeres alkalmazáskiadás

| Összetevő | Rögzített digest |
| --- | --- |
| backend | `sha256:56e84c3fad30428e9dce1563690e682b0a15dc41d6c5f6771856cafd87d79772` |
| frontend | `sha256:7002727b5b06470ac7e25e5c4095e63eb291e0a4763605015dfb432b9a609714` |

A VPS `.release.env` fájlja először ezt a sikeres párt rögzítette; a későbbi automatikus kiadás módosítja. Az alkalmazás első indulása előtti, még üres adatbázisról mentés készült: `backups/20261024T090122-247015`. Ez a mentés az indulás előtti állapotot őrzi; nem a már működő alkalmazás teljes mentése, és nem jelent restore-próbát.

### Belső alkalmazás- és restore-próba

- A `backups/20261024T090312-248340` valódi alkalmazásmentés visszaállítása a külön `diku-restore-20261024153350` Compose projektben **sikeres**. Ellenőrzőösszegek, SQL import és normalizált dump byte-egyezés, uploads `tar diff`, visszatöltött backend UP és `/api/courses` próba sikeres.
- A mentett uploadarchívum **üres** volt: a fájltároló visszaállítási szerkezete ellenőrzött, valódi tananyagfájl byte-egyezési próbája még nincs. A tesztkonténerek leállítva, az elkülönített restore-volume-ok megmaradtak; az éles volume-ok nem voltak restore-célok.
- Az éles VPS belső Nginx → API útvonalán **sikeres** az adminbelépés, sessionrotáció, Secure/HttpOnly cookie, hiányzó CSRF-re 403, anonim adminlekérésre 401, `no-store`, két csoport lekérése és kilépés. Ez belső ellenőrzés; nem külső HTTPS-próba és nem teljes tanulói/fájlhozzáférési regresszió.
- A bootstrap admin env értékek eltávolítva a védett konfigurációból. A backend konténer újralétrehozása utáni **healthy állapot igazolt**.
- Az első admin hozzáférése SFTP-vel a helyi, Gitből kizárt `database/secrets/initial-admin.txt` átadófájlba került; a Gitignore ellenőrzött. Tartalmát ne jelenítsd meg, és ne másold dokumentációba, naplóba vagy Gitbe.

### Automatizáció és dokumentációs kiadás

- Mindkét timer 17:37 Budapest időtől enabled/active. A napi backup üteme 03:30 Europe/Budapest + jitter; az ellenőrzéskor a következő futás **2026-10-25 03:34:37 CET**, az óraátállítás után. Ez ütemezési igazolás, nem egy már lefutott napi mentés eredménye.
- A frontend `89d9eb20849243bbadcf6dac78a346bf26e75b93` és backend `d16203a3d204ec89d6674f36e2a38ce4ebc9a3b8` main commitok dokumentációs változások; API-kód nem változott. Mindkét CI sikeres: frontend `40107897873`, backend `40107902247`.
- A frontend új image-ét a VPS timer **automatikusan telepítette**: `sha256:5f7ed2b634119d0c0440e03f77c9637845931c2c17ced543ee8beb5a3c90b703`. Deploy előtti mentés: `backups/20261024T153939-424142`. A teljes adatbázis normalizált dumpja egyezik a mentéssel.
- Az új backend image automatikus telepítése is **sikeres**, előtte mentés készült: `backups/20261024T154230-426336`. A 23:02 Europe/Budapest ellenőrzéskor a deploy service `Result=success`, `ExecMainStatus=0`, mindkét timer aktív. Az automatikus frissítés óta a naplóban ellenőrzött, változatlan kiadást vizsgáló körök „Nincs új kiadás” eredményt adtak. Mindkét alkalmazás main push → CI → GHCR → timer → VPS ciklusa igazolt.

**Aktív `.release.env` image-pár a 23:02-es ellenőrzéskor:**

| Összetevő | Aktív digest |
| --- | --- |
| backend | `sha256:9f65bcbe8210d3f7fab641260471f67697923b7e929452b08184afe433200837` |
| frontend | `sha256:5f7ed2b634119d0c0440e03f77c9637845931c2c17ced543ee8beb5a3c90b703` |

### Záró VPS-ellenőrzés és backup service

- Mindkét végleges image-digest megegyezik a GHCR `main` és megfelelő teljes commit SHA tagjával. Négy konténer healthy; nincs hostra publikált alkalmazás-/DB-port, nincs bootstrap admin email/jelszó a backend környezetében, nincs pending vagy recovery deployállapot.
- A teljes adatbázis normalizált SQL dumpja egyezik **mindkét automatikus frissítés előtti mentéssel** (`20261024T153939-424142`, `20261024T154230-426336`). Az adatmegőrzés ezen a dokumentációs kiadáson igazolt; API vagy séma nem változott.
- Frissítés után a belső Nginx útvonalon főoldal 200, `/kurzusok` 200, `/api/courses` 200, anonim adminlekérés 401, ismeretlen oldal 404 és API `no-store` ellenőrzés sikeres. Ez továbbra sem külső HTTPS-próba.
- A `diku-backup.service` **kézi systemd-indítással, a valódi uniton sikeresen lefutott**: `Result=success`, `ExecMainStatus=0`, mentés `backups/20261024T210241-588022`. A backend utána healthy; mindkét timer enabled/active maradt.
- A napi backup **naptári ütemezése ellenőrzött**, a service végrehajtása a fenti kézi indítással külön igazolt. A következő hajnali naptári futás még jövőbeli esemény; a telepítés lezárásához nem várunk rá, és nem jelöljük már lefutottként.
- Lemezállapot a záró ellenőrzéskor: 30 GB összesen, 7,8 GB használt, 21 GB szabad, a rendszer által jelzett foglaltság 28%. Külső mentés és automatikus ritkítás továbbra sincs bekötve.

### Sikeres CI-futások

| Repó | GitHub Actions run ID | Eredmény |
| --- | --- | --- |
| frontend | `40000371668` | Sikeres |
| backend | `40000380881` | Sikeres |
| database | `40000711702` | Sikeres |

Az első alkalmazáscommitok: frontend `27c7d2e764a08c3047de8d70ebb4572a69c3f4c0`, backend `9c4e758b3cea10d86235219d751b085942f84c59`.

## Még folyamatban / szükséges

- **Későbbre halasztva a felhasználó kérésére:** DNSSEC-állapot és Microware névszerverváltás, majd aktív zóna, nyilvános DNS és apex/www HTTPS ellenőrzése. A domain Microware-nél marad; nem történik domaintranszfer. Ezek nem akadályozzák a belső VPS-ellenőrzések folytatását.
- A későbbi nyilvános aktiváláskor útvonalat/queryt megőrző www → apex 301, API/privát cache-kivételek és tényleges HTTPS-belépés ellenőrzendő. A www CNAME önmagában nem HTTP-átirányítás.
- A napi mentések későbbi naptári futásának üzemeltetési követése; a szolgáltatás tényleges végrehajtása és a naptári ütemezés már külön-külön igazolt.
- Nyilvános HTTPS-en az auth-ellenőrzéseket a domain átállása után meg kell ismételni; valódi tananyaggal a fájl-visszaállítási próba még hátravan. Hibás image tényleges VPS-rollback próbája külön ellenőrzés.
- Külső mentési cél/megőrzés/riasztás; majd a külső másolatból is ellenőrzött restore-próba.

A nyilvános domain aktiválása későbbre halasztva; az automatikus VPS-frissítés és a mentési ütemezés már aktív. Jelszó, token, személyes fiókadat vagy szervercím nem szerepel ebben a dokumentumban. Folytatási útmutatók: [DEPLOYMENT](DEPLOYMENT.md), [Cloudflare és domain](CLOUDFLARE-SETUP.md).
