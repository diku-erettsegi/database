# Webes jelentkezés és biztonság – érdekmérlegelési munkalap

Adatkezelő: BrainCorp Hungary Kft.; felelős: Varga Balázs ügyvezető. Verzió:2026-11-13. A publikus tájékoztatóhoz tartozó, megismerhető indokolás. Új adatcél/adatkör/jogosultság vagy szolgáltató esetén felülvizsgálandó; az ügyvezető a tényleges eljárást és hozzáférőket is ellenőrizze.

## Nem szerződő résztvevő adatainak kezelése

Cél: szülő által kezdeményezett tantermi képzés megszervezése és a résztvevőhöz rendelése. Érdek: a tanuló kért felkészülésének és a kapcsolattartásnak biztosítása. A szerződő fél saját adataihoz szerződés-előkészítés/szerződésteljesítés jogalap tartozik, nem szükséges minden célra jogos érdeket használni.

Szükségesség: tanuló neve és tág életkori kategóriája kell ahhoz, hogy a szülő megkeresését a megfelelő résztvevőhöz kössük és a kiskorú eljárást megkülönböztessük. Csoport/dátum/igény nélkül a kért jelentkezést nem lehet feldolgozni. Pontos születési adat, okmányszám, iskola, egészségi adat nem kell az online szándékjelzéshez, ezért nincs ilyen kötelező mező. Telefonszám a kért egyszeri szervezői egyeztetéshez kell; a nyilvános e-mail alternatív érdeklődési út.

Hatás: kiskorúak miatt fokozott figyelem szükséges. Az elvárható cél a kért képzés előkészítése, nem marketing vagy harmadik félnek történő értékesítés. A szervező szülőn keresztül tájékoztatást ad, a tájékoztatót a diákkal is meg kell ismertetni. Nagykorú haladásáról szülőnek csak külön tanulói felhatalmazással adható információ.

Garanciák: minimális adatkör; optionalüzenethez figyelmeztetés; privát, szerepkörrel védett admin; ügyvezetői hozzáférés; titkosított továbbítás; csoporthoz kötött portál; nem szerződött lezárt ügy90napos törlése; hozzáférési/tiltakozási/törlési jog; nincs publikált résztvevőlista vagy automatikus felvételi döntés. Tiltakozásnál egyedi vizsgálat és csak a feltétlenül szükséges kezelés folytatható; a puszta szándékjelzés szabadon visszavonható.

Következtetés: a fent korlátozott adatkör és használat mellett a szervezési érdek érvényesíthető, az érintetti jogok és a kiskorú különös védelme megtartásával. Ettől eltérő adatcélra ez a lap nem ad jogalapot.

## Rendszerbiztonság és adminisztrátori napló

Cél: jogosulatlan belépés, tömeges beküldés és adatvesztés megelőzése; adminműveletek visszakeresése. A munkamenet, CSRF, IP-alapú átmeneti kérésszám-korlát és rövid műveletnapló ehhez szükséges. Kevésbé invazív alternatíva az űrlapok és privát fájlok védelmét nem biztosítaná ugyanolyan módon; harmadik fél követőkódja/marketinganalitika nem szükséges.

Hatás: IP, időpont, művelet és célrekord összekapcsolható felhasználóval. Nem naplózunk jelszót, session/CSRF tokent vagy teljes jelentkezési törzset. Hozzáférés csak üzemeltetéshez, nem teljesítményértékeléshez vagy reklámhoz. A biztonsági log/audit30napos, a kérésszám-korlát átmeneti. Dokumentált incidensnél csak az ügyhöz szükséges bizonyíték különíthető el, indokolt külön határidővel.

Garanciák: HTTPS/Tunnel, belső Dockerhálózat, nem nyilvános adatbázis és fájlok, CSRF/sessionrotáció, erős jelszólenyomat, időalapú naplóselejtezés, mentéshozzáférés korlátozása. A külső infrastruktúra nemzetközi adattovábbítási feltételeit a szolgáltatói szerződések rendezik; ez a lap nem helyettesíti a DPA-t vagy az adattovábbítás vizsgálatát.

Következtetés: a szolgáltatás védelméhez szükséges, korlátozott idejű kezelés arányos a fenyegetésekkel. Új megfigyelési/analitikai cél, hosszabb megőrzés vagy szélesebb hozzáférés esetén új értékelés kell.
