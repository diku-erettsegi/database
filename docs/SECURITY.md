# Biztonság és adatkezelési határok

Frissítve: 2026-10-21. A jelenlegi működés szerződése a [backend API](../../backend/API.md); az ellenőrzések eredménye a [HANDOFF](HANDOFF.md). Az alábbiak technikai határok és élesítés előtti döntések, nem kész jogi tájékoztató.

## Jogosultságok

| Szereplő | Elérés |
| --- | --- |
| Látogató | Publikus oldalak/csoportárak, CSRF token, jelentkezés, programozós érdeklődés, belépés |
| Aktív tanuló | Saját sessionadat, minden közzétett óra és azok letöltése |
| Admin | Jelentkezések/státusz/megjegyzés, kézi programozós érdeklődőkezelés, userek, minden óra és fájl, legutóbbi 200 audit esemény |

A frontend nem biztonsági határ. Spring Security védi az admin végpontokat; a letöltés külön vizsgálja, hogy az óra publikált-e. Két jelentkezési csoport van, de nincs csoportonkénti vagy diákonkénti tananyaghozzárendelés: minden aktív diák minden publikált órát lát.

## Meglévő védelmek

HttpOnly/SameSite=Lax session, élesben Secure; CSRF minden módosító kéréshez, session/token váltás belépéskor. Jelszó BCrypt12, a régi session role/password/email/tiltás változásra érvénytelen. Az utolsó admin védett. Paraméterezett JPA hozzáférés és bemeneti korlátok. Privát UUID uploadok, 20MB, attachment/octet-stream/nosniff, fájlok nem futnak és nem csomagolódnak ki. HTTPS meetinglink és React szöveg-escaping. API no-store, publikus stacktrace nélkül. Nginx CSP, frame tiltás és biztonsági headerek.

Egy példányos memóriaalapú limit van: jelentkezés 10/óra/IP, programozós érdeklődés 10/óra/IP és 3/óra/normalizált e-mail, belépés 8/10 perc/IP. Az ismétlések is beleszámítanak; újraindításkor a számláló nullázódik. Ez nem teljes spamvédelem. Productionben a tunnel által adott IP/protokoll megbízhatósága miatt a frontend/backend nem nyitható közvetlenül internetre. A Docker group host szintű hozzáférést jelent: csak az üzemeltető deploy fiókja legyen tag.

## Új beküldések és árak

A jelentkezés és a programozós érdeklődés is explicit `privacyAccepted:true` értéket és CSRF-védelmet kér. A kliens UUID-ja és a normalizált üzleti tartalom ujjlenyomata biztosítja az idempotens ismétlést. Eltérő tartalom ugyanazzal UUID-val 409; a nyilvános visszaigazolás nem szivárogtatja ki az admin belső megjegyzését vagy a teljes rekordot.

A férőhely és díj szerveroldali szabály. Csoportsorzár mellett csak legfeljebb 24 rekord fogadható el; a jelentkezési időpont, csoport és ár-pillanatkép státuszváltással nem módosul. A kedvezmény legfeljebb 35%, a baráti rész önbevallás; admin ellenőrzése továbbra szükséges. Ez nem online fizetés vagy könyvelési bizonylat. A baráti megjegyzéshez ne kérjünk más személy elérhetőségét.

A programozós érdeklődés külön célú név/e-mail nyilvántartás, `NEW`, `CONTACTED`, `COMPLETED` státusszal. A szervezők saját levelezőjükben intézik a megkeresést; az alkalmazás nem küld automatikus e-mailt és nem iratkoztat fel hírlevélre. A V2 `mail_outbox` csak megőrzött történeti tábla, nincs feldolgozva. Az esetleges történeti személyes adatok a megőrzési/törlési tervbe tartoznak.

A production frontend űrlapkapcsoló (`VITE_APPLICATIONS_ENABLED`) csak a felületet tiltja; a nyilvános API-t nem zárja le. Valódi adatgyűjtés előtt véglegesíteni kell a jelentkezés és az érdeklődés külön adatkezelési tájékoztatását és a draft verziókat. Helyben fiktív adatot használjunk.

## Élesítés előtt eldöntendő

- Adatkezelő, tényleges célok/jogalapok, adatfeldolgozók, megőrzési/törlési folyamat, kiskorú jelentkezők kezelése és végleges tájékoztató. A jelenlegi oldal helyőrző, a checkbox és draft verzió nem helyettesíti ezt.
- Valós szervezői elérhetőség; fiókok átadásának és jelszó-helyreállításnak a folyamata. Most az admin állít jelszót; nincs emailes reset vagy MFA.
- Jelentkezések/érdeklődők/audit és történeti outbox adatok célzott törlési és exportfolyamata, lapozás nagyobb adatmennyiségnél. Nincs korlátlan megőrzési ígéret.
- Független backup cél, titkosítás, megőrzési rend, rendszeres visszaállítási próba; tárhely- és memóriafigyelés.
- Cloudflare edge korlátozás, valós HTTPS cookie/CSRF próba, függőségfrissítés és incidens értesítési csatorna. Vírusellenőrzés nincs; csak megbízható admin tölthet fel tananyagot.

A napló nem tartalmaz jelszót, jelentkezési üzenetet vagy érdeklődői megjegyzést. Az audit szereplő e-mailt és rekordazonosítót tartalmaz, tehát szintén védendő adat. Jelszavak, session/CSRF tokenek, valós beküldések, feltöltések és mentések ne kerüljenek Gitbe. A local seed fiókok kizárólag helyi próbához valók; production bootstrap külön egyszeri beállítás.

Az app nem tartalmaz reklám/analitika sütit; a session technikailag szükséges a jelenlegi működéshez. A stockfotók helyben kerülnek kiszolgálásra; forrás/licencnyomuk a képjegyzékben van. Végleges jogi szöveget a szolgáltatás tényleges adatkezelése alapján kell elkészíteni.
