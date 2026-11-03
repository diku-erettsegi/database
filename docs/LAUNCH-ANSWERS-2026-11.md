# Novemberi indulási adatok és megvalósítás

Forrás: a felhasználó 2026-11-03-án átadott `Downloads/message.txt` kérdőíve. A kitöltés üzleti adatforrás; nem kész ÁSZF vagy jóváhagyott adatkezelési tájékoztató. A nyers fájlt nem másoljuk a nyilvános repóba.

## Rögzített tények

- Márkanév: diku-érettségi.hu. Szervező/számlázó/adatkezelő: BrainCorp Hungary Kft, 5711 Gyula, Gát u. 4, adószám 13071097-1-04. Kapcsolattartó/képviselő: Varga Balázs; a végleges szövegek jóváhagyója az ügyvezető.
- Működő e-mail: info@diku-erettsegi.hu; válasz 1 munkanapon belül. Telefonos időszak minden nap 9–19, de telefonszám nincs megadva. Panasz/adatvédelmi megkeresés ugyanide, panasz postán a székhelyre is.
- Folyamat: online szándékjelzés → telefonos egyeztetés → szerződés → befizetés → admin elfogadás. Végleges hely csak befizetés és elfogadás után; nincs automatikus számlázás/fizetés/fióklétrehozás.
- Minimum 14 éves kor, 18 év alatt szülő jár el. Nagykorúnál a diák vagy szülő is szerződhet, a kapcsolattartási címet a szerződő választja. Nincs szintfelmérés vagy előismereti feltétel.
- Általános jelentkezés indulás + 2 hétig; később egyedi egyeztetés. Betelt csoporthoz 5 fős várólista. Csoportváltás szabad hely vagy cserepartner esetén.
- Alanyi adómentes díj (nem „0%-os áfakulcs” címkével). Átutalás/készpénz; legfeljebb 4 részlet, áprilisig. Számlázó: szamlakozpont.hu, számlázási adatokat e-mailben kérik. A felhasználó pontosítása: a korai kedvezményhez a teljes képzési díjnak határidőig be kell érkeznie. Nem vezetünk be 10%-os előlegkötelezettséget az ellentmondó eredeti válaszból. Részletfizetés első részlete a kezdéskor esedékes.
- Baráti kedvezmény csak a barát befizetése után igazolható; külön csoport is lehetséges. Az eredeti feltételes árajánlatot továbbra is megőrizzük, nem nevezzük visszaigazolt fizetendő díjnak.
- Minimum induló létszám 15, maximum 24 fő. Elmaradt oktatói alkalom pótlása egyeztetett időpontban. El nem induló csoport esetén a befizetés visszafizetendő. Helyszín/oktató kiesésekor előzetes e-mailes tájékoztatás.
- Jóváhagyott naptár: 2027-01-09–2027-05-29, minden szombat, 2027-05-15 kihagyásával. Az utolsó két alkalom (május 22. és 29.) szóbeli felkészítés. Az emelt írásbeli május 14., a szóbeli időszak június 2–9. [Hivatalos tanévrend](https://njt.jog.gov.hu/jogszabaly/2026-1-20-9M).
- Diák-visszajelzés a teremben folyamatosan és kérésre. Szülői tájékoztatás kérésre legfeljebb 4 alkalommal, a nagykorú diák tájékoztatási jogosultságát külön rendezni kell.
- Helyszín biztosított: Gábor Dénes Egyetem, 1119 Budapest, Mérnök u. 39. Érkezés 10 perccel korábban; terem/akadálymentes bejutás ügyében a porta segít. Épület/terem még nincs megadva.
- Laptopigény jelentkezéskor; a pontosítás szerint 30 000 Ft a teljes képzésre. A képzési százalékos kedvezmény kizárólag a képzési díjra vonatkozik. Kaució/kárfeltételek is hiányoznak.
- Óránként képernyő- és hangfelvétel; az oktató és kérdéskor a kérdező hallatszik. Csoportok egymás felvételeit nem láthatják. Tanulói hozzáférés elfogadás után, a képzés végét követő egy hónapig; tananyag csak saját tanuláshoz.
- Levelezés Magyar Hosting; tárhely/felvételek Rackforest; nincs külön külső mentési előfizetés, keret 0 Ft, célzott helyreállítás 1 nap. Üzemeltetési kapcsolattartó Varga Balázs, hibajelzéshez az info cím. Ez nem állít már működő e-mailes riasztást.

## Műszaki döntések

- V4 Flyway: várólista, életkori kategória/szülői eljárás, csoporthoz kötött órák és elfogadott jelentkezéshez kapcsolt tanulói jogosultság. Régi adatot nem törlünk vagy árazunk újra.
- Várólista: külön WAITLISTED állapot és kifejezett beküldői választás. Ugyanaz a csoportsorzár védi az 5 várólistás és 24 elfogadott helyet. A várólista nem fizetés vagy végleges helyfoglalás, nincs automatikus előléptetés.
- Kiskorú: csak 14–17 / 18+ kategóriát tárolunk, teljes születési dátumot nem. 14–17 esetén szülő neve és az eljáró szülő nyilatkozata szükséges, backend ellenőrzéssel.
- Tanulói hozzáférés: a backend a közzétételt, csoporttagságot, elfogadott jelentkezést és lejáratot minden óránál és fájlletöltésnél ellenőrzi. Csoport nélkül nincs hallgatólagos közös hozzáférés. Régi, csoport nélküli órákat az admin sorol be.
- Kurzuszárás: szerkeszthető, rendezett 20 dátumos naptár, utolsó napjából képzett végdátum; az egyhónapos jogosultság ebből számolódik budapesti dátummal. Végdátum nélkül új hozzáférést nem adunk határozatlan időre.
- A webes beküldés nem köt szerződést, nem számláz és nem küld automatikus levelet. Csoportváltás nem írja át a beküldéskor mentett árat.

## Pontosítandó az aktiváláshoz

1. A négy részlet pontos összege/napja és bankszámlaadatok. Az előlegkötelezettséget a végleges szerződésben kell egyértelműsíteni; az alkalmazás most nem ír elő külön 10%-ot.
2. Laptop átvételi, visszaadási és kárfelelősségi feltételek.
3. Szoftverek, részletes tematika és próbaalkalmak. A naptár és az utolsó két szóbeli alkalom már jóváhagyott.
4. Cégjegyzékszám, nyilvántartó bíróság, képviselő tisztsége, képzési besorolás/nyilvántartás; nyilvános telefonszám.
5. Adatkezelési célonként jogalap, megőrzési idő és törlés felelőse; felvételhez tájékoztatás/jogalap, megőrzés és alternatíva; szolgáltatók pontos szerződéses adatai, esetleges nemzetközi adattovábbítás.
6. Képzési feltételek, elállás/felmondás, képzés közbeni visszalépés és a baráti kedvezmény visszalépési elszámolása. Az „előleg soha nem jár vissza” szöveg nem tehető közzé ellenőrzött, általános jogi szabályként.
7. Programozási ízelítő végleges anyaga, küldési határidő és megőrzés; portréfájlok; adminok megadása; felvételek mérete és átadásának módja.
8. Riasztás küldéséhez szolgáltató/SMTP hozzáférés, külső mentés tényleges célja és elfogadott adatvesztés. Az e-mail cím megadása nem jelenti azt, hogy léteznek a küldési hitelesítők.

Jogi tájékozódás, nem ügyvezetői/jogi jóváhagyás: [GDPR 13–14. cikk](https://eur-lex.europa.eu/eli/reg/2016/679/oj?locale=hu), [45/2014. Korm. rendelet](https://njt.jog.gov.hu/jogszabaly/2014-45-20-22). Az általános visszalépési szövegben a szerződéskötés módjától függő elállási/felmondási jogokat rendezni kell. Nem találunk ki megőrzési időt vagy általános hozzájárulási jogalapot minden célra.

## Pénzügyi nyilvántartás

A `quoted*`, `baseTotal`, a beküldéskori kedvezményszázalékok és `createdAt` változatlanok. Új jelentkezésnél külön mentett laptopdíj 0/30000, réginél null (nem találjuk ki visszamenőleg).

A szervező külön rögzíti a szerződés ellenőrzését, a képzésre beérkezett összes forintot, a teljes díj beérkezési napját és a már fizető baráti kapcsolatok igazolt számát. Ez kézi összesítő, nem banki szinkron, számlázó vagy befizetési tranzakciós főkönyv. A módosítás auditált. A laptopbefizetés ebben nincs nyilvántartva.

Igazolt korai százalék = minimum(beküldéskori százalék, teljes befizetési dátum szerinti százalék), csak elegendő tényleges befizetésnél. Baráti százalék = 5 × igazolt kapcsolatszám, teljes plafon 35%. Hiányos/nem teljes befizetés mellett nincs igazolt korai kedvezmény; a kezdeti ajánlat ettől még megmarad. A teljes befizetés dátuma nem lehet jövőbeli vagy a jelentkezés előtti. Régi, alapdíj nélküli sorhoz nincs kitalált végösszeg. Elfogadáshoz szerződésigazolás és pozitív befizetés szükséges; részletfizetés megengedett.

## Naptár és hozzáférés

A V4 `course_dates` táblában őrzi a jóváhagyott húsz alkalmat. Adminban szerkeszthető, 20 egyedi, növekvő dátummal; első nap az eredeti indulás. A végdátum a legutolsó alkalom. Kezdeti tanulói lejárat 2027-06-29, a nap végéig Budapest szerint.

A fiók egy elfogadott jelentkezéshez kapcsolható; ugyanazt a jelentkezést két fiókhoz nem lehet hozzárendelni. Csoportváltáskor a hozzáférés az aktuális jelentkezési csoportot követi. Státusz visszavonása, csoport nélküli óra vagy lejárat esetén a fájl közvetlen URL-je is 404. Hozzáférés adása/visszavonása sessionverziót vált. A dátum lejárata hozzáférés-visszavonás, nem adattörlés.

## Bevezetés

Backend és frontend összehangolt kiadás kell: új jelentkezéshez életkori adat, közzétett órához csoport kötelező. A régi órák/fájlok nem törlődnek, de csoport nélkül diáknak nem látszanak. Adminban csoporthoz kell rendelni az órákat, és az elfogadott jelentkezést a tanulói fiókhoz.

A nyilvános űrlap bekapcsolása, a jogi dokumentumok jóváhagyása és az automatikus levelezés külön állapot. SMTP, operátori e-mailriasztás és offsite mentés nincs aktiválva. A fájlkorlát továbbra is 20 MB; teljes órai videókhoz méret/megőrzés és tárhelyterv kell, a jelenlegi letöltő nem videóstreaming szolgáltatás.

## Elkészült adatkezelési tervezet és kiadás

A felhasználó 2026-11-03-án külön átnézendő tervezetet kért: [adatkezelési tájékoztató tervezete](ADATKEZELESI-TAJEKOZTATO-TERVEZET.md). A javasolt jogalapok, megőrzés és felvételi változat még nem jóváhagyott; közzététel és a szükséges műszaki folyamatok megvalósítása külön lépés. A backend/frontend funkciók éles telepítése sikeres, az űrlap engedélyezése változatlan: [HANDOFF](HANDOFF.md), [DEPLOY-STATUS](DEPLOY-STATUS.md).
