# Architektúradöntések

## Telepítési pontosítások – 2026-10-22

### ADR-016 — Rackforest, kimenő Tunnel, külön kezelt DNS

**Döntés:** a meglévő Ubuntu 24.04 VPS futtat kész GHCR image-eket. Cloudflare teljes DNS-zóna és remotely managed Tunnel; a regisztrátor marad a jelenlegi magyar szolgáltató. Bejövő alkalmazás-/DB-port nincs, meglévő levelezési rekordok megőrzendők. A rögzített cloudflared digest külön file-secretből olvassa a tokent; MariaDB frissítése felügyelt.

**Következmény:** az SSH-felmérés elkészült, aktiválás még nem. Az 1 vCPU-t nem terheli build. A proxy csak Tunnel mögött bízhat a Cloudflare fejlécekben; alternatív kliens Forwarded fejléceket az Nginx törli. Részletes konfiguráció és források: DEPLOYMENT.md, CLOUDFLARE-SETUP.md.

### ADR-017 — Csak egészséges kiadás commitolható

**Döntés:** `.release.env` az utolsó egészséges pár; külön pending, failed és recovery-required állapot. Lockolt frissítés, előtte konzisztens DB/fájlmentés, sikertelen pár elkülönítése. Megszakítás után helyreállítás, rollback hiba után operátori ellenőrzés és explicit újrapróbálás. A napi backuphoz külön timer és korlátozott hibaismétlés tartozik.

**Ok:** hibás image ne váltsa felül a működő visszaállítási pontot, és ne okozzon kétpercenként kiesést/új mentést. Leállt, de meglévő DB mellett a script nem frissít mentés nélkül.

**Következmény:** rövid API-kiesés és sessionvesztés vállalt; DB-migráció visszafordítása nem automatikus. Offsite másolat, retention és riasztás még külön beállítandó. A helyi regressziós teszt nem helyettesíti a tényleges staging frissítés/restore próbát.

## Hatályos pontosítások – 2026-10-21

Az alábbiak a [stratégia](STRATEGY-2026-10.md) végleges, október 21-i pontosításait rögzítik. Az alkalmazott migrációkat és a korábbi döntések nyomát megőrizzük. A teszteredményeket a HANDOFF tartalmazza.

### ADR-013 — Összeadódó kedvezmények, maximum 35%

**Döntés:** `min(35, időszakosSzázalék + 5 × max(hozottBarátok, ajánlássalÉrkezik ? 1 : 0))`. A meghívott barát is kap 5%-ot; ugyanazt a kapcsolatot nem számoljuk kétszer. A szerver menti az időszakos és nyers baráti komponenst, a plafonnal korlátozott százalékot és a teljes/tanóradíjat.

**Következmény:** az ár már tartalmazza a bejelentett baráti kedvezményt, jogosultságát az admin kézzel ellenőrzi. Ez felülírja az ADR-010 korábbi, még nyitott összevonási szabályát. V3 új mezőket ad; a V2-ben már mentett árakat nem számolja át. A nyilvános sikerüzenet a backend mentett ajánlatát mutatja.

### ADR-014 — Programozós érdeklődők kézi feldolgozása

**Döntés:** név/e-mail/idempotens kérésazonosító adatbázisban, admin `NEW | CONTACTED | COMPLETED` állapot, belső megjegyzés és módosítási idő. Az alkalmazás nem küld levelet; a szervezők saját levelezőjükből keresik meg az érdeklődőt és küldik a hivatkozást.

**Következmény:** **az ADR-011-et felülírja**. SMTP-függőség, háttérküldő, újraküldési végpont és Mailpit nincs az aktív rendszerben. A V2 történeti `mail_outbox` táblája használaton kívül megmarad, hogy alkalmazott migrációt/adatot ne írjunk át. V3 vezeti be a kézi feldolgozás mezőit. A beküldési siker csak a mentést igazolja; nem állíthat elküldött e-mailt vagy hírlevél-feliratkozást.

### ADR-015 — Stockfotók, követhető eredettel

**Döntés:** az elfogadott vizuális irány valódi stockfotókat használ helyi, optimalizált WebP fájlként. A képjegyzék őrzi a forrást és licencnyomot. A stock nem állíthatja, hogy a saját oktatókat, diákokat vagy tantermet mutatja.

**Következmény:** felülírja az ADR-012 korábbi generáltképes elképzelését. Új AI-generált marketingképet nem készítünk. Oktatói portré csak megfelelő valódi képpel tölthető ki; addig jelölt helyőrző marad.

## 2026-10-20 döntések és történetük

Az ADR-009–012 a [részletes stratégiai tervben](STRATEGY-2026-10.md) szereplő üzleti döntéseket valósítja meg; az alábbi kezdeti döntések történeti állapotát ez a bővítés pontosítja.

### ADR-009 — Csoportonkénti jelentkezés és tranzakciós kapacitás

Két 24 fős csoport és csoporthoz rendelt új jelentkezés. Az elfogadás foglal helyet, zárolt csoportsor mellett ellenőrzött létszámmal; a várakozó érdeklődés nem foglal. Régi jelentkezés csoport nélkül megmarad. A tanulói tananyag-hozzáférés még közös.

### ADR-010 — Szerveroldali ár és változatlan pillanatkép

Budapest szerinti szerveridő választ időszakos kedvezményt. Az ár és a jelentkezés ideje mentett pillanatkép, státuszváltás nem számolja újra. UUID-val ismételhető a beküldés duplikáció nélkül. Az október 20-án még nyitott baráti összevonási szabályt október 21-én az ADR-013 lezárta: a kedvezmények összeadódnak maximum 35%-ig, kézi jogosultság-ellenőrzéssel.

### ADR-011 — Tranzakciós e-mail outbox

**Állapot: felülírva 2026-10-21-én az ADR-014 által. Ez történeti leírás, nem a futó működés.**

Az október 20-i tervben az érdeklődő és a küldési feladat egy DB-tranzakcióban jött létre. Háttérküldő próbálkozott volna újra, az admin látta volna az állapotot és újraindíthatta volna a sikertelen küldést. Helyben Mailpit, élesben opcionális SMTP szerepelt. A mentési siker és az SMTP-átvétel külön állapot volt. Az október 21-i felhasználói pontosítás miatt ezek kikerültek az aktív rendszerből; csak a V2 történeti tábla maradt meg.

### ADR-012 — Hivatalos vizsgafájlokra mutató gyűjtemény

Az előrenderelt, SEO-zott gyűjtőoldal az OH eredeti PDF/ZIP fájljaira hivatkozik, nem másolatokat terjeszt. Verziózott forráslista és ellenőrzési dátum marad a repóban. Ez továbbra is hatályos. Az eredeti generáltképes vizuális elképzelést az ADR-015 stockfotókra módosította.

A dátum minden induló döntésnél 2026-10-17. Állapot: elfogadott kezdeti irány; a telepítési döntések előkészítést jelentenek, nem aktív szolgáltatást. Módosításkor új bejegyzést írjunk, az okkal és következménnyel együtt.

## ADR-001 — React statikus előállítással

**Döntés:** React + TypeScript + Vite; a publikus route-ok tartalma és metaadatai build közben statikus HTML-be kerülnek. Nginx szolgálja ki őket, az admin és diákfelület ugyanebben az alkalmazásban fut.

**Ok:** kevés tartalmi oldal, erős SEO-igény, alacsony VPS-erőforrásigény. Nem kell minden látogatáshoz Node SSR szerver.

**Következmény:** publikus tartalomváltozás új buildet igényel. A route-regiszter, sitemap, canonical és előállított HTML együtt változik. Ismeretlen route valódi 404 legyen; ne minden URL kapjon főoldali 200-at.

## ADR-002 — Spring Boot moduláris monolit

**Döntés:** Java 21, Spring Boot 3.5, Spring Security, MariaDB; egy backend szolgáltatás.

**Ok:** a jelentkezések, órák, fájlok és felhasználók kis rendszerhez tartoznak. A monolit egyszerűbben futtatható és menthető, miközben a kódban a felelősségek elválaszthatók.

**Következmény:** az első telepítés egy példányos. Két jelentkezési csoport már része a rendszernek; a tananyaghoz tartozó csoporttagság, több backend vagy külön médiaszolgáltatás későbbi igény alapján tervezendő. A levelezés az ADR-014 szerint kézi. A pontos függőségeket rögzíteni és rendszeresen frissíteni kell.

## ADR-003 — Same-origin session és CSRF

**Döntés:** a frontend és az API egy origin alatt él; `/api` proxy. Szerveroldali session cookie és CSRF-védett állapotmódosítás, szerveroldali szerepkör-ellenőrzés.

**Ok:** böngészős, saját alkalmazáshoz nincs szükség localStorage-ban tartott bearer tokenre vagy külön OAuth infrastruktúrára.

**Következmény:** a frontend kérjen/frissítsen CSRF tokent a backend szerződése szerint, különösen belépés/kilépés után. A session HttpOnly, élesben Secure. Backend újraindításkor új belépés szükséges lehet. A CSRF nem helyettesíti a jogosultságot vagy a spam elleni védelmet.

## ADR-004 — A séma egyetlen forrása a backend Flyway

**Döntés:** a verziózott DDL a backend `src/main/resources/db/migration` könyvtárában él. A `database` repo környezetet biztosít, nem másol sémát.

**Ok:** a backend és az általa elvárt adatmodell együtt verziózható. Az indulás alkalmazza a hiányzó migrációkat.

**Következmény:** alkalmazott migrációt nem szerkesztünk. Az új változás új verzió, a Hibernate nem `update` módban alakítja a sémát. Az image rollback nem adatbázis-rollback; destruktív migráció külön tervet kíván.

## ADR-005 — Privát fájlvolume egy VPS-en

**Döntés:** az admin által feltöltött fájlok privát volume-ra kerülnek; a metaadat MariaDB-ben. Letöltés csak jogosultságot ellenőrző API-val.

**Ok:** kezdetben kis mennyiségű tananyag, egy szolgáltatáspéldány. Object storage bevezetése most több üzemeltetési feladatot adna.

**Következmény:** DB és fájlok közös helyreállítási pontját menteni kell. A host elvesztése ellen külső mentési cél szükséges. Későbbi többpéldányos működéshez objektumtároló vagy megosztott tárolás kell.

## ADR-006 — Docker Compose és Cloudflare Tunnel

**Döntés:** Ubuntu VPS-en Compose futtatja a frontend/backend/MariaDB/cloudflared szolgáltatásokat. A nyilvános belépési pont `https://diku-erettsegi.hu`; a tunnel a frontend belső portjára vezet.

**Ok:** egy kis VPS-hez egyszerű, verziókezelhető környezet. A tunnel kimenő kapcsolatot hoz létre, az alkalmazáshoz nem kell bejövő publikus hostport. [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/).

**Következmény:** az origin és token védelme, Cloudflare/DNS beállítás, cookie/proxy-beállítás és egészségfigyelés szükséges. A tunnel nem helyettesíti az alkalmazás hitelesítését. Kubernetes és külön bejövő deploy-webhook nem indokolt.

## ADR-007 — Main → ellenőrzött image → digest → automatikus VPS-frissítés

**Döntés:** frontend/backend `main` push után CI fut, sikeres ellenőrzés után GHCR image készül. A VPS systemd timer kétpercenként ellenőrzi a publikált `main` image-eket, és a konkrét digestre áll át. Lock, változásvizsgálat, mentés, health check és korábbi image-pár szükséges.

**Ok:** a futtatószerver kész, CI-ben buildelt csomagot kap; nem fordít forráskódot élesben, és nincs szüksége bejövő webhookra. A digest ugyanarra a tartalomra hivatkozik. [GHCR digest szerinti lehúzás](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry).

**Következmény:** a három repo nem ad automatikusan atomi közös kiadást. A frontend/backend változások visszafelé kompatibilisek legyenek; nagy közös változáshoz kiadási manifest/összehangolt deploy szükséges. Az infra repo változása kezdetben felügyelt frissítés. A MariaDB/cloudflared image frissítése külön üzemeltetési változás, nem a frontend main-jének mellékhatása.

## ADR-008 — Rövid, őszinte tartalom; marketing CMS később

**Döntés:** a publikus oldalak szövege kevés, ismeretlen üzleti adat helyőrző; adminban kezdetben a kurzus működéséhez szükséges adatok szerkeszthetők.

**Ok:** a cél átlátható tájékoztatás és jelentkezés, nem általános tartalomkezelő rendszer.

**Következmény:** az október 20–21-i stratégia megadta az árat, indulást, két csoportot, oktatóneveket és helyszínintézményt. A részletes naptár, valódi portrék, terem, telefon, bérlési/fizetési feltételek és jogi szövegek még hiányoznak. A SEO nem kaphat kitalált címet, értékelést vagy eredményt. A marketing CMS és a tananyag-tagság külön későbbi ütem.
