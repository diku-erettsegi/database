# Termék és tartalmi terv

Frissítve: 2026-10-21. Az elfogadott üzleti részletek hiteles forrása a [stratégia](STRATEGY-2026-10.md); a futtatott ellenőrzéseket a [HANDOFF](HANDOFF.md) rögzíti.

## Cél és megjelenés

Szülőknek és diákoknak áttekinthető, rövid magyar oldal, jól látható „Kurzusok és jelentkezés” útvonallal. A hangsúly a személyes, tantermi emelt digitális kultúra felkészítésen van. Krém/zsályazöld arculat, olvasható tipográfia, levegős szakaszok, visszafogott mozgás és reduced-motion támogatás. Mobilon is egyszerű navigáció, billentyűzettel elérhető kontrollok.

Valódi stockfotókat használunk helyi, optimalizált WebP fájlként, jelölt eredettel. Ezek nem a saját tanterem, diákok vagy oktatók dokumentumfotói. AI-generált marketingkép nem része az elfogadott iránynak. A portrék helyőrzői maradnak, amíg megérkeznek a valódi képek. Források: [IMAGE-ASSETS](IMAGE-ASSETS.md).

## Rögzített képzési adatok

- Kezdés: 2027. január 9.; szombati délelőtti 09:00–13:00 és délutáni 14:00–18:00 csoport.
- 20 alkalom × 4 darab 45 perces tanóra = 80 tanóra. A négyórás idősáv szüneteket is tartalmaz.
- Legfeljebb 24 elfogadott jelentkezés csoportonként; két oktató, Balázs és Peti.
- Budapest XI. kerület, Gábor Dénes Egyetem, Bikás park közelében. Pontos terem és megközelítés még kitöltendő.
- Alapdíj 280 000 Ft, azaz 3 500 Ft/tanóra. Korai és baráti kedvezmény összeadódik, legfeljebb 35%-ig.
- Saját laptop vagy jelzett bérlési igény; a bérleti díj és feltételek még nem véglegesek.
- Tanulói portál, próbaérettségik és javításuk, próbaszóbelik. Eredménygarancia nincs.

A húsz alkalom részletes naptára még egyeztetendő: húsz egymást követő szombat január 9-től május 22-ig tartana. A tantervet az ünnepekhez és a célzott vizsgához kell igazítani; ne publikáljunk kitalált óranaptárt vagy biztos befejezési dátumot.

## Oldaltérkép

18 ismert útvonal és külön 404 oldal. A konkrét title/description/canonical a frontend `src/seo.ts` fájljában él.

| URL | Feladat |
| --- | --- |
| `/` | Emberközeli áttekintés, kurzusválasztás, programozós érdeklődés |
| `/kurzusok` | Két csoport, aktuális díj/férőhely, jelentkezési űrlap |
| `/jelentkezes` | Megőrzött jelentkezési útvonal, ugyanazzal a funkcióval |
| `/szuloknek` | Időbeosztás, költség, segítség, rövid szülői válaszok |
| `/diakoknak` | Gyakorlás, óramenet, felszerelés, felkészülés |
| `/oktatas-menete` | Témák, 45 perces tanórák, próbaérettségi és tananyag |
| `/oktatok` | Balázs és Peti bemutatkozása, valódi portrók helye |
| `/arak` | Alapár, két korai időszak, baráti összevonás, 35% plafon |
| `/helyszin` | Gábor Dénes Egyetem, hiányzó terem/megközelítés jelölve |
| `/gyik` | Rövid, valós kérdések és válaszok |
| `/kapcsolat` | `info@diku-erettsegi.hu`, jelölt és nem hívható telefonhelyőrző |
| `/erettsegi-feladatsorok` | Öt időszak húsz eredeti OH PDF/ZIP hivatkozása |
| `/programozas-izelito` | Rövid, noindex Python-példa kézi megosztáshoz |
| `/adatkezeles`, `/impresszum` | Noindex jogi piszkozatok |
| `/belepes`, `/tanulo`, `/admin` | Noindex belépési és szerepkörös felületek |

## Jelentkezési folyamat

1. A látogató kiválasztja a délelőtti vagy délutáni csoportot. Az aktuális ár és szabad hely a backendtől érkezik.
2. Megadja a tanuló nevét, e-mailt, telefonszámot; opcionális a gondviselő neve, üzenet, baráti megjegyzés és laptopigény. A „Hány barátot hozol?” mező és a „Barát ajánlásával érkezem” jelölő együtt adja a kedvezményt.
3. Az előzetes ár az időszakos kedvezményhez hozzáadja a baráti 5%-okat, maximum 35%-ig. A barátszám `max(hozott barátok, ajánlással érkezik ? 1 : 0)`, ugyanazt a kapcsolatot nem számolja kétszer.
4. Beküldéskor a backend menti az időpontot és a tényleges díjat. Sikerüzenet csak valós mentés után jelenik meg, a mentett árból. A hálózati újrapróbálás azonos UUID-val nem duplikál.
5. Az admin kapcsolatba lép és feldolgozza a jelentkezést. Csak az `ACCEPTED` foglal helyet; az új jelentkezés nem fizetés, nem végleges helyfoglalás és nem automatikus diákfiók.

A baráti kedvezmény jogosultsága kézi ellenőrzést igényel, de a mentett ajánlat már tartalmazza a bejelentett kedvezményt. A laptopbérlés díját nem találjuk ki és nem adjuk automatikusan a képzési díjhoz.

## Programozós érdeklődés

A főoldali rövid űrlap nevet, e-mailt és a tájékoztató megismerését kéri. Tartós, idempotens rekordot hoz létre. Az admin külön listában `NEW`, `CONTACTED`, `COMPLETED` státusszal és belső megjegyzéssel kezeli. A szervezők saját levelezőjükben intézik a kapcsolatfelvételt és a linkküldést. Nincs automatikus e-mail, küldési sor, SMTP-állapot vagy hírlevél-feliratkozás; a sikerüzenet a mentést igazolja.

## Admin és diák

Az admin csoport és státusz szerint szűrheti a jelentkezéseket, látja az elfogadott létszámot, a beküldés változatlan budapesti időpontját, a mentett díjat/kedvezménybontást és a barát/laptop adatokat. A státusz és belső megjegyzés szerkeszthető; a korábbi csoport nélküli rekordok külön szűrhetők.

Megmarad a felhasználókezelés, szerepkör/tiltás/jelszó, óraszerkesztés, időpont/HTTPS értekezletlink, publikálás, fájlfeltöltés/törlés és audit. Az admin nem marketing CMS. Minden aktív tanuló minden publikált órát és fájlt lát; a jelentkezési csoport még nem tananyag-tagság.

## Még kitöltendő

| Tétel | Következő döntés |
| --- | --- |
| Részletes naptár | Húsz alkalom, ünnepek, vizsgához igazítás |
| Fizetés és lemondás | Jóváhagyott ütemezés és feltételek |
| Baráti jogosultság | Kézi egyeztetés és dokumentálás módja |
| Laptopbérlés | Díj, készlet, feltételek |
| Oktatói portrék | Valódi képek felhasználási engedéllyel |
| Helyszín | Épület/terem, közlekedés, hozzáférhetőség |
| Telefon | Valós szám; a helyőrző nem `tel:` link |
| Jogi oldalak | Adatkezelő, célok, megőrzés/törlés, üzemeltető adatai |
| Programozási ízelítő | Végleges oktatói anyag és kézi megosztás menete |

Ne kerüljön az oldalra kitalált eredmény, vélemény, partneri kapcsolat vagy bizonyítatlan oktatási/piaci összehasonlítás. A felvételi beszámítás szakfüggő. A technikai elfogadási és tesztállapot a HANDOFF-ban követhető.