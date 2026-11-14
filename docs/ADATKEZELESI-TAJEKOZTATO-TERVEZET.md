# Adatkezelési tájékoztató – átnézendő tervezet

**Történeti dokumentum.** A 2026-11-13/14-i válaszok és döntések felülírják az alábbi nyitott kérdések megválaszolt részeit. Aktuális szöveg: frontend/src/LegalPages.tsx; döntések és szervezői eljárás: [LAUNCH-2026-11-13](LAUNCH-2026-11-13.md); technikai megőrzés: [RETENTION](RETENTION.md); élesítés állapota: [DEPLOY-STATUS](DEPLOY-STATUS.md). Ezt a korábbi tervezetet ne publikáld a jelenlegi tájékoztató helyett.

**Verzió: tervezet-2026-11-03. Nem hatályos, nem közzétett tájékoztató.**

A dokumentum a szervező által megadott adatok és az alkalmazás jelenlegi működése alapján készült. A „Javaslat” és „Jóváhagyandó” részek még döntést igényelnek. Ezek nem már működő törlési szabályok vagy kész jogi állásfoglalások. Közzététel előtt adatvédelmi/jogi felülvizsgálat és az ügyvezető jóváhagyása szükséges; ezután az alkalmazás működését is hozzá kell igazítani. Ez a dokumentum nem ÁSZF és nem rendezi az elállás vagy visszatérítés feltételeit.

Jóváhagyó neve, tisztsége: **[kitöltendő]**  
Jóváhagyás napja / hatálybalépés / végleges verzió: **[kitöltendő]**

## 1. Ki kezeli az adatokat?

- Adatkezelő: **BrainCorp Hungary Kft**.
- Székhely és postai cím: **5711 Gyula, Gát u. 4**.
- Adószám: **13071097-1-04**.
- Honlap: **https://diku-erettsegi.hu**; márka: diku-érettségi.hu.
- Adatvédelmi és ügyfélszolgálati e-mail: **info@diku-erettsegi.hu**.
- Kapcsolattartó: **Varga Balázs**.
- Cégjegyzékszám, nyilvántartó bíróság, képviselő pontos tisztsége: **[kitöltendő]**.

Az „ügyvezető” kapcsolattartóként való megadása nem jelent igazolt adatvédelmi tisztviselői kinevezést. **Jóváhagyandó:** szükséges-e kijelölt tisztviselő; ha van, neve és elérhetősége. Addig a fenti cím adatvédelmi kapcsolattartási címként szerepeljen.

## 2. Kiket érint a tájékoztató?

A honlap látogatóit, a képzés iránt érdeklődőket, jelentkezőket, várólistásokat, tanulókat, az eljáró szülőket/törvényes képviselőket, a szerződő vagy számlafizető személyeket és a portál felhasználóit. A jelentkezést 14 éves kortól fogadjuk; 18 év alatt szülő/törvényes képviselő jár el. A 14 éves kor a képzés részvételi feltétele, **nem általános adatvédelmi hozzájárulási korhatár**.

Az adatokat elsősorban az érintett vagy az eljáró szülő adja meg. A szülő által megadott tanulói és a baráti kedvezmény egyeztetésekor közvetetten kapott adatok esetében külön rendezendő, hogyan jut el a tájékoztató magához az érintetthez. Más személy elérhetőségét ne írják a szabad szöveges mezőkbe.

## 3. Milyen célból, milyen adatokat kezelünk?

Az alábbi jogalapok **felülvizsgálandó javaslatok**, a megőrzési idők jóváhagyása a 4. pontban történik. A szerződéshez szükséges adatkezelést nem célszerű egy általános, mindenre kiterjedő hozzájárulásként kezelni; az érintett és a szerződő személy szerepét célonként kell azonosítani. [Európai Bizottság: adatkezelési jogalapok](https://commission.europa.eu/law/law-topic/data-protection/information-business-and-organisations/legal-grounds-processing-data_en).

| Cél | Adatkör és működés | Javasolt jogalap / tisztázás |
| --- | --- | --- |
| Képzéssel kapcsolatos megkeresés | Név, e-mail, megadott telefon, üzenet és válaszok; a kapcsolattartást munkatárs végzi. | Konkrét szerződéskötési érdeklődésnél GDPR 6. cikk (1) b). Egyéb általános megkeresésnél külön értékelendő a válaszadáshoz fűződő jogos érdek, 6. cikk (1) f). |
| Jelentkezés, egyeztetés, várólista | Tanuló neve, kapcsolattartási e-mail és telefon, 14–17 / 18+ kategória, szükség szerint szülő neve és eljárásának jelölése, választott csoport, laptopigény, opcionális üzenet. Beküldési idő, státusz, egyeztetési megjegyzés, kérelemazonosító, tájékoztató verziója és megismerésének időpontja. | A leendő szerződő saját adatainál 6. cikk (1) b). A nem szerződő tanuló/szülő adatainál a képviseleti és szerződési modellt előbb tisztázni kell; jogos érdek választása esetén külön, gyermekekre is kiterjedő érdekmérlegelés szükséges. Nem alkalmazunk automatikusan minden résztvevőre szerződéses jogalapot. |
| Kedvezmény és fizetés ellenőrzése | Eredeti feltételes ajánlat, kedvezményadatok, barátok bejelentett és igazolt száma, opcionális egyeztetési megjegyzés, laptopdíj, szerződés ellenőrzése, képzésre beérkezett összeg, teljes befizetés napja. Az admin kézzel igazolja. | Szerződőnél 6. cikk (1) b); számviteli bizonylattá váló részénél 6. cikk (1) c). Másik tanulóhoz kapcsolás és közvetetten kapott adatok kezelésének feltételei külön jóváhagyandók. Másik jelentkező befizetésének részleteit nem adjuk ki a kedvezményezettnek. |
| Tanulói portál, képzés | Név, e-mail, jelszó ellenőrzésére szolgáló hash, szerepkör, aktív állapot, elfogadott jelentkezéshez kötés, csoport és hozzáférési idő. Tananyagok és a tanulónak adott egyéni visszajelzések. | Szerződő tanulónál a szükséges működéshez 6. cikk (1) b). Szülővel kötött szerződés tanulói adataira a fenti szerepértékelés szükséges. A szülői tájékoztatás jogosultját külön ellenőrizni kell; nagykorú diáknál nincs automatikus hozzáférés a szülőnek. |
| Programozási ízelítő kérése | Név, e-mail, kérés időpontja/azonosítója, tájékoztató megismerésének nyoma, teljesítési státusz és belső megjegyzés. A linket munkatárs küldi. | Javaslat: külön, önkéntes hozzájárulás a kért anyag elküldésére, 6. cikk (1) a). Ennek szövege és bizonyítható kezelése még nincs véglegesítve. Nem hírlevél-feliratkozás, nem felhatalmazás további reklámlevelekre. |
| Számlázás és számvitel | A számlához szükséges név/cégnév, cím, szükség szerinti adószám, díj és teljesítési/fizetési adatok; ezeket jelenleg külön e-mailben kérik, kézi számlázással. | Jogszabályi kötelezettség, 6. cikk (1) c); a könyvelővel pontosítandó, mely nyilvántartás minősül számviteli bizonylatnak. |
| Biztonság, hibakeresés | Munkamenet-azonosító, kéréshez kapcsolódó technikai adatok és napló, admin auditban végrehajtó, művelet, célrekord és időpont; ideiglenes kérésszám-korlátozás. | Javaslat: a szolgáltatás védelméhez fűződő jogos érdek, 6. cikk (1) f), dokumentált szükségességgel és érdekmérlegeléssel. Naplótípusonként megőrzés szükséges. |
| Panasz, érintetti kérelem, jogvita | Kapcsolattartás, a kérelem/panasz tartalma és kezelése, szükséges bizonyítékok. | Kötelező ügyintézéshez 6. cikk (1) c); indokolt jogigényhez külön 6. cikk (1) f). A panasz típusához tartozó konkrét jogszabály és megőrzés még kitöltendő. |

Az alap jelentkezési adatok nélkül a szándékjelzés nem bírálható el; a kötelező mezőket az űrlap jelöli. A szülő neve és eljárási nyilatkozata kiskorúnál kötelező. Az üzenet és a baráti megjegyzés nem kötelező. Nem kérünk teljes születési dátumot, személyazonosító okmány másolatát vagy egészségügyi adatot az űrlapon; ilyen adatot a szabad szövegben se adjanak meg.

A kedvezményes ajánlat számítása automatikus, a fizetés ellenőrzése és a jelentkezés elfogadása emberi döntés. A megadott kedvezmény nem jelent automatikus felvételt vagy végleges helyfoglalást. Az alkalmazásban nincs hírlevélküldő vagy reklámprofilozó funkció.

## 4. Megőrzési idők – döntési javaslat

**Az alábbi nem kötelező időtartamok javaslatok, és jelenleg nincsenek automatikusan kikényszerítve.** A végleges szövegben csak vállalható, ténylegesen végrehajtott szabály szerepelhet. A törlési felelős kijelölése és az eljárás megvalósítása együtt szükséges.

| Adatkör | Javasolt idő / kezdő esemény | Döntés |
| --- | --- | --- |
| Egyszerű érdeklődés, levelezés | Az ügy lezárása után 90 nap; szerződéssé alakuláskor csak a szükséges részek kerülnek a szerződési iratokhoz. | [jóváhagyandó] |
| Nem elfogadott jelentkezés/várólista | A visszalépéstől vagy végleges elutasítástól 90 nap. Le nem zárt jelentkezések felülvizsgálata legkésőbb a kurzus végén; ne maradjanak határozatlan ideig NEW státuszban. | [jóváhagyandó] |
| Ízelítőkérés | Kiküldéstől vagy visszavonástól 30 nap; nem teljesített kérést legfeljebb 90 nap után felülvizsgálni és lezárni. | [jóváhagyandó; küldési vállalás is hiányzik] |
| Tanulói fiók, nem szükséges működési adatok | Hozzáférés a képzés végét követő egy hónapig; az ezután már nem szükséges fiókadatok törlése/anonimizálása további 30 napon belül. A 2027-es csoportnál hozzáférés június 29. végéig, javasolt takarítás július 29-ig. | A hozzáférés lejárata jóváhagyott és működik; a törlés javaslat. |
| Órai felvétel, személyhez köthető pedagógiai jegyzet | Legfeljebb a tanulói hozzáférés végéig; elsődleges példányok törlése az azt követő 30 napon belül. | [jóváhagyandó; felvételi szabály nélkül nem indulhat felvételkészítés] |
| Nem számviteli szerződéses bizonyíték | Csak a szükséges dokumentumok elkülönített megőrzése; konkrét idő **[jogi felülvizsgálattal kitöltendő]**. Nem az egész portáladatbázis általános megőrzése. | [kitöltendő] |
| Számviteli bizonylatok | Legalább 8 év az alkalmazandó számviteli kötelezettség szerint; a kezdőpontot és az iratkört a könyvelővel rögzíteni. | Jogszabályi minimum; nem terjeszthető automatikusan minden személyes adatra. |
| Technikai szervernapló | 30 nap, incidensnél az érintett rész elkülönítése, dokumentált ügyhöz kötött határidővel. | [jóváhagyandó és konfigurálandó] |
| Admin audit | 90 nap; kötelező pénzügyi bizonyítékot külön nyilvántartásban kell megtartani. | [jóváhagyandó és megvalósítandó] |
| Panaszok és érintetti kérelmek | A konkrét eljárásra vonatkozó kötelező vagy indokolt idő **[kitöltendő]**. | [jogi felülvizsgálat szükséges] |
| Biztonsági mentések | Gördülő, legfeljebb 30 napos megőrzés; a napi és telepítés előtti példányokra is. Visszaállítás után a korábbi törléseket újra végrehajtani. | [jóváhagyandó; jelenleg nincs automatikus selejtezés] |

A számviteli bizonylatok legalább nyolcéves megőrzésének alapja a számvitelről szóló 2000. évi C. törvény 169. § (2). [Jogszabály](https://njt.jog.gov.hu/jogszabaly/2000-100-00-00), [NAIH-határozat a szabály alkalmazásáról](https://naih.hu/files/NAIH-2019-1841_hatarozat.pdf). Az alkalmazás kézi befizetés-összesítője önmagában nem helyettesíti a könyvelést vagy a számlázórendszert.

Törlés felelőse: **[javaslat: Varga Balázs; elfogadás szükséges]**. Helyettese: **[kitöltendő]**. Javasolt havi ellenőrzés, határidőnapon ütemezett végrehajtással; egyedi joggyakorlási kérelem nem várhat a következő havi ellenőrzésig. A törlésnek az adatbázis mellett az e-mailekre, exportokra, munkapéldányokra, feltöltésekre és a mentések életciklusára is ki kell terjednie. A szükséges pénzügyi iratok külön megőrzendők.

## 5. Órai képernyő- és hangfelvételek – külön jóváhagyandó rész

**A szervező terve:** az oktatói képernyőt és hangot rögzítik; a kérdező diák hangja is rákerülhet. Cél a pótlás és az ismétlés, hozzáférő a saját csoport és a feladatot ellátó munkatársak. Más csoport nem férhet hozzá. A portál csoportonkénti jogosultságellenőrzése elkészült, a felvételkészítés jogalapja és törlési folyamata nincs véglegesítve. A rendszer nem rögzíti automatikusan az órát.

**Javasolt döntés:** alapértelmezetten csak az oktatói képernyő és hang kerüljön a felvételre; a diák kérdését az oktató személyazonosítás nélkül ismételje meg. Ez az eredeti működési terv módosítása lenne, ezért nem tekintjük jóváhagyottnak. A képernyőről is ki kell zárni az e-mail-címeket, neveket, értesítéseket és más szükségtelen személyes adatot.

Ha a diák hangját is rögzítik, javaslatként csak elkülönült, önkéntes, visszavonható hozzájárulási folyamatot készítsünk elő, megfelelő szülői/kiskorú részvétellel, jogi felülvizsgálat után. A visszautasítás nem járhat a képzés, kérdezés vagy tananyag elérhetőségének elvesztésével; biztosítani kell felvétel nélküli kérdezést, szükség esetén szüneteltetést vagy utólagos kivágást. [EDPB: jogszerű adatkezelés és önkéntes hozzájárulás](https://www.edpb.europa.eu/sme/be-compliant/process-personal-data-lawfully_en).

**Eldöntendő és utána megvalósítandó:**

1. Pontosan milyen képet/hangot, milyen eszközzel és ki rögzít; megjelenik-e diák neve vagy képe online csatlakozásnál?
2. Melyik felvételi változatot választják, és mi a személyenként/célonként ellenőrzött jogalap? Az oktatók felvételeinek jogalapját és felhasználási engedélyét is rendezni kell.
3. Hogyan kap tájékoztatást a távolról csatlakozó, a késve érkező és a kiskorú; hogyan bizonyítható a szükséges nyilatkozat?
4. Ki állítja le a rögzítést, ki vágja ki a visszavont részt, milyen határidővel; hogyan használható az óra rögzítés nélkül?
5. Hol van a nyers, szerkesztett és mentett példány; ki törli, mikor; a felvevő gépen és az értekezletszolgáltatónál marad-e másolat?
6. Csak megtekintés vagy letöltés is lesz? A jelenlegi portál fájlt ad letöltésre, nem védett videóstreamet; a korábban letöltött másolat technikailag nem vonható vissza. Ezt a célhoz, hozzájáruláshoz és feltételekhez kell igazítani.

A jelenlegi általános adatkezelési jelölőnégyzet **nem helyettesíti** a felvételekhez szükséges külön tájékoztatást/nyilatkozatot. Felvételek reklámcélú vagy nyilvános felhasználása ebben a tervezetben nem szerepel.

## 6. Ki fér hozzá, milyen szolgáltatók működnek közre?

A szervező kijelölt adminisztrátorai és a feladatukhoz szükséges körben az oktatók. A felhasználói listát és a hozzáférések rendszeres felülvizsgálatának felelősét még rögzíteni kell. Az admin technikailag az összes csoportot kezelheti; a diák a saját elfogadott jelentkezéséhez kötött csoport anyagát látja a jogosultság lejártáig. Nem állítunk a jelenleginél szűkebb adminjogosultságot.

| Szolgáltatás | Megadott név és szerep | Véglegesítéshez hiányzik |
| --- | --- | --- |
| VPS, adatbázis, fájlok, helyi mentések | Rackforest; szerverüzemeltetés/tárhely | Pontos szerződő jogi személy, cím, adatkezelési hely, adatfeldolgozási megállapodás és alvállalkozók. |
| DNS, HTTPS-forgalom és Tunnel | Cloudflare; a webes forgalom közvetítése, nem kizárólag DNS | Szerződés szerinti jogi személy/szerepkörök, naplózás, feldolgozási országok, megőrzés és esetleges nemzetközi továbbítás garanciái. |
| E-mail | Magyar Hosting; érdeklődések és szervezési levelek | Pontos jogi személy, cím, szolgáltatás, levelezési mentések, megőrzés, megállapodás. |
| Számlázás | szamlakozpont.hu; kézi számlázás | Szolgáltató pontos jogi személye, cím, adatfeldolgozói feltételek. A könyvelő és bank azonosítása/szerepe is kitöltendő. |
| Online részvétel, ha alkalmazzák | Például Teams, a tényleges szolgáltatás még pontosítandó | Előfizető, szolgáltató, belépéskor átadott adatok, saját felvétel és naplózás, önálló tájékoztató. Nem tekintjük már bekötött szolgáltatásnak. |

A Gábor Dénes Egyetem a megadott működés szerint helyszínt biztosít, jelentkezési adatokat nem kap. Ha beléptetéshez később névsort kér, az új adatátadást előbb értékelni és a tájékoztatóban rendezni kell.

Nem állítható a jelenlegi információkból, hogy minden adat kizárólag Magyarországon vagy az EGT-ben marad. A nemzetközi adattovábbítás címzettjeit, országait, tényleges garanciáját és a garanciák megismerhetőségét a szerződések alapján kell kitölteni: **[kitöltendő]**. A szolgáltatói márkanév nem helyettesíti ezt a vizsgálatot. Az adatfeldolgozói szerephez megfelelő szerződéses rendezés is szükséges. [Európai Bizottság: adatkezelő és adatfeldolgozó](https://commission.europa.eu/law/law-topic/data-protection/information-business-and-organisations/application-gdpr_en).

## 7. Sütik és technikai működés

A jelenlegi alkalmazás saját kódjában nincs analitika, reklámkövető vagy közösségi követőkód. A belépés és a kérések védelme munkamenetet használ. A `JSESSIONID` szükséges munkamenetsüti; a szerveroldali inaktivitási idő jelenleg 60 perc. Ez nem a fiókadatok megőrzési ideje és nem minden napló lejárata. A CSRF-token a munkamenet védelméhez kapcsolódik, nem marketingazonosító.

**Közzététel előtti ellenőrzés:** az éles böngészőből teljes süti-/helyitár-leltár készüljön anonim, belépett és Cloudflare-védelmi helyzetben; név, szolgáltató, cél, lejárat szerint. A Cloudflare vagy később beágyazott külső tartalom működését nem lehet pusztán a saját forráskód alapján kizárni. Nem vezetünk be elemző vagy marketingcélú sütit e tervezet alapján.

## 8. Hogyan lehet jogot gyakorolni?

Írjon az **info@diku-erettsegi.hu** címre vagy a székhelyre. Megfelelő azonosítás után, az adott jog feltételei szerint kérhető hozzáférés és másolat, helyesbítés, törlés, korlátozás vagy adathordozhatóság; jogos érdeken alapuló kezelés ellen tiltakozni lehet. Hozzájárulás bármikor visszavonható, a korábbi jogszerű kezelés ettől nem válik visszamenőleg jogellenessé. Kötelező iratmegőrzés miatt nem minden adat törölhető azonnal.

A kérelemre indokolatlan késedelem nélkül, főszabály szerint egy hónapon belül kell választ adni. Összetettség vagy a kérelmek száma miatt további két hónap hosszabbítás lehetséges; ennek okáról az első hónapon belül tájékoztatást kell adni. Az általános ügyfélszolgálati egy munkanapos válaszvállalás nem helyettesíti ezt az eljárást. [NAIH: érintetti jogok](https://www.naih.hu/erintetti-jogok).

Panasz tehető a **Nemzeti Adatvédelmi és Információszabadság Hatóságnál**, illetve bírósági jogorvoslat vehető igénybe. A hatósági beadvány benyújtásának módját a [NAIH hivatalos ügyfélszolgálati oldala](https://www.naih.hu/ugyfelszolgalat-kapcsolat) ismerteti; a sima e-mail nem helyettesíti a hivatalos eljáráskezdeményezést. Az adatkezelő előzetes megkeresése nem feltétele a hatósághoz fordulásnak.

## 9. Belső megvalósítási és jóváhagyási lap – nem publikus tájékoztatószöveg

Az alábbi rész a szervező és a későbbi fejlesztők munkalistája. A végleges publikus tájékoztatóba ne kerüljön be.

- [ ] A cégadatokat, szerepköröket, képzési jogállást és jogszabályi iratőrzési kötelezettségeket ellenőrizték. Jóváhagyó és hatálybalépés kitöltve.
- [ ] Célonként kiválasztották a jogalapot; a szerződő szülő/nagykorú tanuló és a nem szerződő résztvevő külön kezelve; szükséges érdekmérlegelések elkészültek.
- [ ] Jóváhagyták az időtartamokat, a törlési felelőst és helyettesét, a panaszok/érintetti kérelmek határidejét; a fiók, alkalmazásrekord, audit, e-mail, felvétel és mentés kezelése összehangolt.
- [ ] Szolgáltatók pontos adatai, szerepe, megállapodások és esetleges nemzetközi továbbítás kitöltve; külső értekezlet csak kiválasztás után szerepel végleges tényként.
- [ ] Döntöttek a felvételekről, elkészült a szükséges külön nyilatkozat és a rögzítés nélküli alternatíva; felvevő eszköz, tárhely, letöltés és törlés működése megfelel a szövegnek.
- [ ] A szülői tájékoztatás jogosultságellenőrzése és a közvetetten kapott adatok tájékoztatási folyamata kész.
- [ ] Az ízelítő anyaga, küldési vállalása és külön nyilatkozata végleges; nincs összekapcsolva hírlevéllel.
- [ ] Az űrlapok tájékoztató-megismerési szövege és a hozzájárulásos célok külön nyilatkozatai megfelelőek; a tárolt verziók a tényleges végleges szövegre mutatnak.
- [ ] Éles süti-/helyitár-leltár ellenőrizve; új követőkód nem került be.
- [ ] Törlés/anonimizálás, napló- és mentésmegőrzés megvalósítva és ellenőrizve. A hozzáférés lejárata önmagában nem adattörlés.

**Műszaki állapot 2026-11-03:** a csoporthoz kötött letöltés, hozzáférés-lejárat és admin audit működik. Nincs ütemezett személyesadat-törlés, mentésselejtezés, felvételi hozzájárulás-kezelés vagy automatikus levelezés. Az admin audit 200 soros megjelenítése nem 200 soros adatmegőrzési korlát; a konténernapló méretrotációja nem napokban vállalt törlés. Az admin szerepkör széles hozzáférésű. A feltöltési korlát 20 MB, teljes órai videóhoz külön kapacitás- és hozzáférési terv kell.

A backend még `draft-2026-10`, illetve `programming-preview-draft-2026-10` verziót tárol új kérelmekhez. A tervezet elkészítése nem módosítja ezeket és nem változtatja meg a történeti rekordokat. A véglegesítéskor verzióváltás kell a megfelelő backend-folyamatban és azonos szöveg/link a frontendben. A jelenlegi `privacyAccepted` elnevezés nem bizonyít minden célra jogszerű hozzájárulást.

A nyilvános jelentkezési felület buildkapcsolója jelenleg kikapcsolt; ez felületi korlát, **nem szerveroldali API-tiltás**. E dokumentum nem változtatja meg az éles kapcsolókat. A tervezetet a felhasználó külön átnézésre kérte; ne publikálja későbbi agent kész, jóváhagyott tájékoztatóként. A jóváhagyott szöveghez igazított működés és a jelentkezés megnyitása külön kiadás.
