# Megőrzés és napi selejtezés

2026-11-14. Üzleti forrás, felelős és kézi eljárások: [LAUNCH-2026-11-13](LAUNCH-2026-11-13.md). Tényleges éles aktiválás: [DEPLOY-STATUS](DEPLOY-STATUS.md). A méretrotáció nem helyettesíti az időalapú megőrzést.

## Alkalmazás

Backend V5 / RetentionService: napi 03:15 Europe/Budapest, `RETENTION_CRON` változóval módosítható. Műveletenként tranzakció és az adminfolyamattal egyező zárolás; kizárólag darabszámot naplóz. API és részletes adatmodell: backend/API.md.

- A kurzus vége után lezárja a szerződés/befizetés nélküli nyitott jelentkezéseket; lezárt REJECTED/WITHDRAWN adat 90 nap elteltével törlődik, ha nincs kapcsolt fiók vagy megőrzési védelem.
- Szerződés vagy befizetés valaha megtörtént: a `retention_protected` tartósan véd. Visszafizetés/státuszváltás nem oldja fel; a kötelező idő utáni irattári selejtezés külön, kézi felülvizsgálat.
- Ízelítő COMPLETED esetén completed_at+90 nap; nyitott kérés created_at+90 nap. Visszavont hozzájárulásnál külön admin DELETE, azonnali adateltávolítás; nem kell kivárni90 napot. A történeti mail_outbox kapcsolt sora is törlődik.
- Tanulói fiók visszavont vagy természetesen lejárt hozzáférése után30 nap: törlés. Adminfiókot nem érint, a törölt fiók sessionje következő kéréskor401. A kurzus végéhez kötött szükségtelen message/notes/referral_note külön törlődik, a szükséges pénzügyi törzs nem.
- Audit30 nap. A listában látható200elem nem retenció.
- V5 migráció nem töröl adatot; ismeretlen korábbi lezárási/kiküldési időnek új kezdőpontot ad. V1–V5 élesítés után immutable.

## Mentés

`scripts/backup-retention.sh [--dry-run]`: közös deploy/backup lock, UTC-formátumú könyvtárnév szerinti30 nap, napi 04:30as persistenttimer, backuphibától függetlenül. A régi részleges mentések is lejárnak. Csak a saját backups közvetlen, ismert időbélyeges könyvtárait és ismert fájljait kezeli. Symlink, mountpoint, váratlan név/tartalom kimarad, kézi felülvizsgálatot igényel. Új backupformátumnál script és teszt együtt változzon. Offsite/export/restorevolume nem kerül automatikusan e szabály alá.

## Naplók

Production Compose: mind a négy konténer journald driverrel. `scripts/install-retention.sh` a dedikált Ubuntu 24.04 host alapértelmezett journaljára (minden szolgáltatásra)30 napot, legfeljebb1napos fájlegységeket és256 MB korlátot állít. Napi04:45kor külön root service rotál/vacuumol, persistenttimerrel, hibánál korlátozott újrapróbával. A napokban megadott szabályt napi kör és fájlegységek hajtják végre; nem másodpercre pontos törlési ígéret. Méretkorlát miatt korábbi törlés lehetséges.

A journald restart már érintheti a régi naplókat. A telepítő backupselejtezést nem indít, csak enablezi a timereket; indítás külön. A konténer loggingdriver újralétrehozáskor változik: régi json-file napló nem válik journald-adattá. Külön syslog/fájllog és imjournal olvasó ellenőrizendő. Külső Cloudflare/levelező naplókra ez a konfiguráció nem vonatkozik.

## Telepítés

Előtte izolált scriptfixture-tesztek, Bash-szintaxis, Compose-config. Roottelepítést csak a dedikált VPS-en szabad futtatni.

```sh
cd /opt/diku/database
sudo -u diku-deploy bash scripts/backup-retention.sh --dry-run
sudo bash scripts/install-retention.sh
sudo systemd-analyze verify /etc/systemd/system/diku-*-retention.service /etc/systemd/system/diku-*-retention.timer
sudo systemctl start diku-backup-retention.timer diku-journal-retention.timer
sudo systemctl list-timers 'diku-*retention.timer'
```

Már jóváhagyott30 napos retención belül a dry-run technikai célhalmaz-ellenőrzés, nem minden napi futásra kért új engedély. Ismeretlen könyvtárat ne törölj találgatással. Soha ne használj általános volume-prune-t vagy `down -v`-t frissítéshez.

Visszaállítás előtt a mentés óta teljesített kézi törlések és lejáratok újra alkalmazandók, még a publikus megnyitás előtt. Izolált restore után az ideiglenes volume/export is törlendő pontos név és label alapján, nem tartható meg határozatlan ideig második archívumként.

Forrás: [Docker journald](https://docs.docker.com/engine/logging/drivers/journald/), [systemd journald.conf](https://www.freedesktop.org/software/systemd/man/latest/journald.conf.html).
