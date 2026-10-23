# Rackforest VPS: telepítés és automatikus frissítés

Frissítve: **2026-10-23**. A tényleges telepítés megkezdődött, aktuális teljesített lépések: **[DEPLOY-STATUS](DEPLOY-STATUS.md)**. Az alábbi eljárásleírás önmagában nem végrehajtási igazolás. Kiinduló szerveradatok: [SERVER-AUDIT](SERVER-AUDIT-2026-10-22.md); teszteredmények: [HANDOFF](HANDOFF.md).

## Választott működés

```text
frontend / backend main push
    → GitHub Actions: teszt → Docker build → GHCR :main + commit SHA
    → VPS systemd timer: ellenőrzés kétpercenként
    → új image-digest → közös DB + fájlmentés
    → Docker Compose frissítés → egészségellenőrzés
    → siker: kiadás rögzítése / hiba: előző image-pár visszaállítása

Böngésző → Cloudflare HTTPS → titkosított Tunnel → frontend:80
                                                      ↓ /api
                                                 backend:8080 → db:3306
```

A szerver kész image-eket húz le, nem a forráskódot fordítja. A main push után nincs kézi SSH vagy újraindítás. Átfutás: GitHub teszt/build ideje + körülbelül kétperces timer-várakozás + letöltés/indulás. A GitHub nem kap VPS SSH-jogosultságot; nincs bejövő deploy-webhook vagy CI runner az éles gépen.

Ez egygépes frissítés, rövid kieséssel. A mentés idejére a backend leáll, újraindítása megszünteti a memóriában tárolt sessionöket. A statikus tájékoztatók eközben elérhetők maradhatnak, az API és a jelentkezés átmenetileg nem. Nem ígérünk megszakításmentes kiadást.

**Automatikus:** frontend/backend kiadások, a backenddel érkező új Flyway migrációk. **Felügyelt:** a `database` infrastruktúra-repó, Ubuntu, MariaDB és cloudflared frissítése. Ezek a tárolt adatokhoz/hálózathoz nyúlnak, ezért külön ellenőrzött üzemeltetési kiadást kapnak. Az infra main validál, nem módosítja automatikusan a VPS konfigurációját.

A két alkalmazásrepo kiadása nem atomi. Előbb visszafelé kompatibilis backend, utána frontend szükséges; Flyway esetén először hozzáadó változtatás. Törő változásnál állítsd le a timert, rögzíts és tesztelj összetartozó image-párt. Az image rollback **nem** fordítja vissza a DB-migrációt.

## Szerver és előfeltételek

A meglévő Rackforest gép Ubuntu 24.04.5 LTS, x86_64, 1 vCPU, kb. 4 GB RAM és 30 GB lemez, a felméréskor 23 GB szabad. Kis forgalmú induláshoz észszerű kiindulás; még nincs terheléses mérés. A fordítás GitHubon fut. Compose memóriahatárok: backend 1024 MB, MariaDB 768 MB, frontend 128 MB, cloudflared 256 MB. Feltöltések, image-ek és mentések lemezfoglalását együtt kell figyelni.

Szükséges hozzáférések: GitHub organization/repo/Actions és privát GHCR package-ek olvasása; SSH-s operátor és Rackforest helyreállítási konzol; regisztrátori névszerver/DNS-jog és Cloudflare-zóna; külső mentési cél és üzemeltetési riasztások címzettje.

Az első két alkalmazásimage-nek már léteznie kell a GHCR-ben. A main első pushja október 23-án megtörtént; az aktuális CI-eredményt a DEPLOY-STATUS rögzíti. A `main` legyen védett, ellenőrzött PR-okkal. Mindkét workflow csak sikeres teszt után publikál. A frontend `APPLICATIONS_ENABLED` repository variable alapértelmezése `false`. Ez **csak a felület kapcsolója**, nem tiltja a backend végpontot. Staging esetén a teljes hostot korlátozd, és végleges tájékoztatók előtt ne irányíts rá nyilvános adatgyűjtést.

## Egyszeri Ubuntu-előkészítés

Az alábbiak eljárásleírások; végrehajtási állapotuk a DEPLOY-STATUS-ban van. A Docker/felhasználó-előkészítés ismételhető scriptje: `scripts/provision-ubuntu.sh` (root, Ubuntu 24.04 amd64). Kulccsal elérhető üzemeltetői fiókot második SSH-ablakban próbálj ki a sudo joggal együtt. Root/jelszavas belépést csak ez és a Rackforest konzol ellenőrzése után szigoríts.

Docker Engine és Compose plugin a [hivatalos Ubuntu apt-tárolóból](https://docs.docker.com/engine/install/ubuntu/):

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl git python3 util-linux
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: noble
Components: stable
Architectures: amd64
Signed-By: /etc/apt/keyrings/docker.asc
EOF
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo adduser --disabled-password --gecos '' diku-deploy
sudo usermod -aG docker diku-deploy
sudo install -d -m 0750 -o diku-deploy -g diku-deploy /opt/diku
```

A `diku-deploy` Docker-csoporttagsága gyakorlatilag hostszintű jogosultság. Ne használd alkalmazásbeli fióknak. Bejövő SSH-t a tényleges üzemeltetői címekről engedj; alkalmazás-, DB- és Docker API-portot ne nyiss. Tűzfalat csak a működő SSH és konzol megőrzésével módosíts. A Docker publikált portjai megkerülhetik az UFW-t, ezért a production Compose-ban egyáltalán nincs `ports` bejegyzés.

## GitHub és GHCR

A szerverre csak a `database` repo kell. Privát repónál a klónozáshoz külön, **csak olvasható repository deploy key** használható. A GitHub szerverkulcsát ellenőrzött fingerprint alapján vedd fel; ne kapcsold ki a hostkey-ellenőrzést. Már beállított hozzáféréssel:

```bash
sudo -iu diku-deploy
git clone --branch main git@github.com:diku-erettsegi/database.git /opt/diku/database
cd /opt/diku/database
docker version
docker compose version
python3 --version
```

Privát image-ekhez a `diku-deploy` saját Docker-konfigurációjába jelentkezz be. GHCR-hez **classic PAT `read:packages` joggal**, mindkét package-et olvasni képes fióktól; szervezeti SSO esetén annak engedélyezése is kell. A klónozási kulcs nem helyettesíti. A CI saját `GITHUB_TOKEN`-nel publikál, PAT nem kell hozzá. [GHCR hitelesítés/digest](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry).

```bash
read -rp 'GitHub felhasználónév: ' registry_user
read -rsp 'GHCR read:packages token: ' registry_token
printf '\n'
printf '%s' "$registry_token" | docker login ghcr.io --username "$registry_user" --password-stdin
unset registry_token registry_user
chmod 700 "$HOME/.docker"
chmod 600 "$HOME/.docker/config.json"
```

Credential helper nélkül a Docker config nem titkosítja a hitelesítést; a host fájljogai védik. Ne töltsd fel Gitbe vagy naplóba. Kövesd a PAT lejáratát/rotálását. Nyilvános package esetén pullhoz nem szükséges bejelentkezés.

## Konfiguráció és titkok

```bash
cd /opt/diku/database
umask 077
cp .env.production.example .env.production
chmod 600 .env.production
install -d -m 0700 secrets
editor .env.production
editor secrets/cloudflared-token
chmod 0644 secrets/cloudflared-token
```

Minden `CHANGE_ME` értéket cserélj, a DB- és rootjelszó eltérő, véletlen érték legyen. Például az `openssl rand -hex 32` megfelelő karakterkészletű titkot készít; kizárólag a védett fájlba kerüljön. A Compose envet ne `source`-old. Kerüld a shellből exportált azonos nevű változókkal történő véletlen felülírást.

A `BOOTSTRAP_ADMIN_EMAIL/NAME/PASSWORD` csak üres felhasználótáblánál készíti az első admint; productionben nincs demó seed. Első belépés után vedd ki az értékeket az envből, majd tervezett rövid leállással hozd újra létre a backend konténert, hogy a régi érték ne maradjon a környezetében. A bootstrap nem állít át már létező jelszót.

A tokenfájl csak a tényleges Tunnel tokent tartalmazza. A rögzített cloudflared image `65532:65532` felhasználóval fut. Ezért a fájl **0644**, de a host szülőkönyvtára **0700**: más hostfelhasználó nem járhatja be. A konténer a csak hozzá rendelt Compose secreten olvassa. A file-backed secret nem titkosított vault, és a bind mount `uid/gid/mode` átírására nem támaszkodunk. [Compose secrets](https://docs.docker.com/compose/how-tos/use-secrets/).

MariaDB/cloudflared verzió és digest a `.env.production.example` fájlban rögzített. MariaDB 11.4.10 a helyi integrációban használt változat; cloudflared 2026.10.3 image-letöltése és CLI-je ellenőrzött, éles Tunnel-kapcsolata még nem. Frissítésük külön tesztelt infra-kiadás.

## Cloudflare és a magyar domain

**Cloudflare Tunnelt javaslunk.** A domain a magyar regisztrátornál marad; az autoritatív DNS névszerverei kerülnek Cloudflare-hez. Pontos lépések, megfigyelt NS/MX és DNSSEC/levelezés megőrzése: [CLOUDFLARE-SETUP](CLOUDFLARE-SETUP.md). A meglévő `mail.diku-erettsegi.hu`, MX/SPF/DKIM/DMARC rekordokat nem írjuk át a webes VPS-re.

A remotely managed Tunnel originje `http://frontend:80`. A www → apex 301 megőrzi az útvonalat/queryt; HTTPS kötelező. A VPS kimenő 7844 UDP/TCP kapcsolatot használ, plusz DNS/HTTPS-t a letöltésekhez. Bejövő webport nincs. Külső regisztrátor mellett támogatott a teljes DNS-beállítás; a névszerverváltás nélküli partial/CNAME setup magasabb csomaghoz kötött másik megoldás. [Névszerverek](https://developers.cloudflare.com/dns/nameservers/update-nameservers/), [Tunnel](https://developers.cloudflare.com/tunnel/get-started/).

A cloudflared healthcheck a connector kapcsolatát ellenőrzi, nem a nyilvános DNS-t/tanúsítványt. A frontend csak a Tunnel belső hálózatán érhető el: a proxy a Cloudflare kliens-IP/protokoll fejléceiben bízik. A kliens alternatív `Forwarded` és kapcsolódó fejléceit az Nginx eltávolítja. A session cookie Secure; belépés/CSRF valódi HTTPS-en is tesztelendő. Privát/API tartalomra nincs megosztott cache.

## Első indítás és timerek

Kész image-ek, kitöltött env és Tunnel konfiguráció után:

```bash
cd /opt/diku/database
bash scripts/preflight.sh
bash scripts/deploy.sh
docker compose --project-name diku --env-file .env.production --env-file .release.env -f compose.production.yml ps
```

A preflight csak ellenőriz, titkot nem ír ki, envet nem futtat. Jogosultságokat, image pinelést, éles profilt/cookie-t és hostportok hiányát vizsgálja. A deploy automatikusan is meghívja. Első telepítéshez nincs korábbi visszaállítási pont. Meglévő DB-konténer/adatvolume mellett, ha a DB nem fut, a deploy megáll; nem indít migrációt mentés nélkül. Először a DB-t kell helyreállítani és menteni.

Első siker után ellenőrizd az apex/www HTTPS-t, bejelentkezést, jogosultságokat, jelentkezést és privát fájlt. Tesztadatot kijelölt stagingbe vagy elkülönített, előre egyeztetett éles próbával írj. A meglévő `smoke-test.mjs` szándékosan csak localhoston fut.

Ezután a sudo-képes üzemeltetői fiókkal:

```bash
sudo install -m 0644 /opt/diku/database/systemd/diku-deploy.service /etc/systemd/system/
sudo install -m 0644 /opt/diku/database/systemd/diku-deploy.timer /etc/systemd/system/
sudo install -m 0644 /opt/diku/database/systemd/diku-backup.service /etc/systemd/system/
sudo install -m 0644 /opt/diku/database/systemd/diku-backup.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now diku-deploy.timer diku-backup.timer
systemctl list-timers diku-deploy.timer diku-backup.timer
journalctl -u diku-deploy.service -u diku-backup.service -n 80
```

Deploy: boot után 2 perccel, majd az előző futás vége után 2 perccel, legfeljebb 15 s szórással. Napi backup: 03:30 Europe/Budapest, legfeljebb 5 perc szórással, kimaradt naptári futást a systemd pótol. A scriptek közös flock-ot használnak. Lockütközéskor a deploy kihagyja a kört; a backup hibával kilép. A backup service hiba után 5 perccel újrapróbálkozik, kétórás ablakban legfeljebb 3 indulásig. Tartós hiba után kézi javítás/pótlás kell; a Persistent=true önmagában nem ismétel sikertelen futást. A timerek még nincsenek a VPS-en telepítve/engedélyezve.

## Kiadási állapot és hiba

| Fájl | Jelentés |
| --- | --- |
| `.release.env` | Utolsó sikeres, egészséges backend/frontend digestpár |
| `.deploy/previous.env` | A próbálkozás előtti sikeres pár; rollback után azonos lehet az aktuálissal |
| `.deploy/pending.env` | Folyamatban lévő/félbehagyott próbálkozás |
| `.deploy/failed.env` | Hibás pár, nem próbálja újra kétpercenként |
| `.deploy/recovery-required` | Sikertelen helyreállítás; operátori beavatkozás kell |

A release csak healthcheck után íródik át. Megszakadt frissítésnél a következő futás felismeri a pending állapotot és az utolsó sikeres párt állítja vissza. **Megszakadt első telepítésnél nincs ilyen pár:** a pending megmarad, a futás megáll, operátori állapotellenőrzés és `bash scripts/deploy.sh --retry-failed` szükséges. Hibás jelöltet elkülönít; új image-pár ismét próbálható, ugyanaz csak javítás után a fenti kapcsolóval. Sikertelen rollback blokkolja a további automatikus módosítást.

Hibaelhárítás: `sudo systemctl stop diku-deploy.timer diku-backup.timer`, service napló és konténerállapot vizsgálata. A már futó oneshot végét is ellenőrizd; a timer leállítása nem szakítja meg. Ellenőrzés/javítás után a `--retry-failed` sikeres rollback-health esetén maga törli a recovery jelzőket; normál esetben ne töröld őket kézzel. Registry-, konfiguráció- vagy mentési hiba után új kiadás nem indulhat.

## Mentés és helyreállítás

`bash scripts/backup.sh`: az aktív backend leáll, SQL dump és privát uploads archívum készül ugyanahhoz az írásmentes állapothoz. Önálló mentés után visszaindítja a korábban futó backendet és megvárja a healthchecket. Deploy közben sikeres mentés után a backend állva marad, közvetlenül az új kiadás indul, így nem érkezhet új írás a mentés és migráció közé.

A csomag `backups/<UTC idő>-<pid>/` alá kerül, meglévő release-párral és SHA256SUMS ellenőrzőösszeggel. Csak ellenőrzött dump/archívum kap COMPLETE jelzőt. Infrastrukturális jelszavak és Tunnel token nem kerülnek bele, de a DB személyes adatokat és felhasználói jelszóhasheket tartalmaz: a mentés védett adat. A művelet hibáját/újraindítási hibát a script hibakóddal jelzi.

Minden deploy előtti és napi mentés megmarad. **Automatikus ritkítás és offsite másolás nincs implementálva/aktiválva**, mert cél és megőrzési szabály nincs megadva. Induló javaslat: napi titkosított másolat a VPS-től független tárhelyre, 7 napi + 4 heti példány, valamint minden használt rollback pont. Ezt az adatmegőrzéssel/tárhellyel egyeztetni kell. Ellenőrzött külső másolat nélkül ne törölj automatikusan helyi mentést.

A napi mentés legfeljebb 24 órás célzott adatvesztési ablakot ad csak működő másolás/visszaállítás mellett; ez nem mért SLA. Jelentkezési időszakban sűrűbb mentés mérlegelendő. Helyreállítási idő külön próbával mérendő. Első restore-próba: izolált Compose projekt, új volume-ok, ugyanazon COMPLETE csomag DB-je/fájljai és kompatibilis image-pár; rekordok és fájl byte-jainak ellenőrzése. Éles volume soha ne legyen tesztcél.

Éles restore: mindkét timer leállítása; futó service-ek és függő újrapróbálkozások megszűnésének ellenőrzése; a közös `.deploy/deploy.lock` kizárólagos zárolása; jelen állapot külön mentése; minden író leállítása; közös SQL/fájlmentés visszatöltése; kompatibilis image-ek; ellenőrzés; timerek visszaengedése. Pending/recovery állapotban az önálló backup.sh szándékosan tiltott: a hibás jelen állapot megőrzése ilyenkor külön operátori eljárás, nem sikeres release-ként címkézett mentés. Ez felülíró művelet: parancsait a kiválasztott mentéshez és tényleges volume-nevekhez kell elkészíteni. Mentés óta érkezett jelentkezések külön egyeztetést igényelnek. `down -v` és `docker system prune --volumes` nem normál frissítési/takarítási parancs.

Figyelés: független HTTPS monitor, systemd hibák, utolsó sikeres deploy/backup, lemez 80% figyelmeztetés / 90% sürgős jelzés, RAM/OOM és health. Docker logkorlát 10 MB × 3 / szolgáltatás; backup/image külön nő. Automatikus image-prune nincs: futó és rollback digestet őrizni kell. Riasztási csatorna még nincs bekötve. Az alkalmazás továbbra sem küld e-mailt.

## Indulás előtt még szükséges

1. Első commit/push, sikeres Actions és olvasható GHCR package-ek.
2. Kulcsos operátor, Docker/Compose, kitöltött konfiguráció és első éles admin.
3. Cloudflare-zóna/Tunnel/token, teljes DNS-leltár, egyeztetett névszerverváltás, HTTPS/levelezés ellenőrzése.
4. Staging sikeres frissítés és hibás image visszaállítása, majd production útvonal tesztje.
5. Külső mentési cél, restore-próba, riasztás és végleges publikus/adatkezelési tartalom.

A konfiguráció, helyi teszt és szerverfelmérés nem jelenti ezek végrehajtását. A teljesített lépéseket a HANDOFF-ban vezesd tovább.
