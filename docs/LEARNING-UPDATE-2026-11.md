# Tantermi és otthoni tanulás, kedvezményhosszabbítás

Felhasználói döntés: 2026. november 14.; megvalósítás és ellenőrzés: november 15.

## Kedvezmény

- Super Early Bird: 25%, **2026. november 25. nap végéig, Europe/Budapest**.
- Early Bird: 15%, november 26-tól december 15. nap végéig.
- A teljes kedvezményes képzési díjnak a határidőig be kell érkeznie; az előleg önmagában továbbra sem elég.
- A baráti kedvezménnyel együtt legfeljebb 35% adható. A laptopdíj külön tétel.
- A backend `CoursePricing` szabálya közös a publikus árhoz és az igazolt pénzügyi összesítőhöz. Az eredeti mentett ajánlat/időpont/idempotens ismétlés megmarad; nincs adatátírás vagy migráció.
- A frontend árak, kurzusok/jelentkezés, GYIK és részvételi tájékoztató ugyanazt a november 25-i határt közlik. A korábbi, dátumozott dokumentumok november 15/16 értékei történetiek; ezt a döntést ne írják felül.

## Tartalom és felépítés

A főoldal, az Így tanulunk, a Szülőknek és a Diákoknak oldal egységes, képes kérdés–válasz blokkokkal mutatja be a módszert. A `frontend/src/LearningContent.tsx` és a hozzá tartozó CSS megosztott, előrenderelhető komponenseket ad, a szülői és diákoldalon eltérő kérdésekkel.

A felhasználó által vállalt tanítási szolgáltatás: feladatmegoldásra épülő gyakorlati órák; két oktató körbejár és segít; személyes kérdezési lehetőség; pluszfeladatok a gyorsabban haladóknak; minden óra oktatói felvételének otthoni visszanézése; segítő fájlok és külön, saját időben végezhető otthoni gyakorló feladatsorok. A szombati tantermi munka és az otthoni ismétlés egymást egészíti ki. A saját gyakorlás szükségessége és a szülői visszajelzés korábban jóváhagyott feltételei megmaradnak.

**Felvételkezelési határ:** kizárólag az oktató hangja és képernyője rögzíthető; a diák hangja, képe és neve nem. Ez a tartalmi kiadás nem valósít meg automatikus órarögzítést, videóstreaminget vagy új videótárolást. A felvételek előállítását és a szabályos hozzáférést a szervezőnek a képzés indulásáig biztosítania kell; a meglévő 20 MB-os fájlfeltöltés nem teljes órai videóplatform.

Meglévő helyi Pexels stockfotók használata; nincs AI-kép vagy új külső képletöltés. Források: [IMAGE-ASSETS](IMAGE-ASSETS.md). Egyedi oldalmetaadatok, egy H1 és meglévő canonical útvonalak; a kezdőlapi tantermi digitális kultúra felkészítő főcím megmarad. Új útvonal, API-mező vagy függőség nem kell.

## Felvételi állítások

Nem ígérünk mindenkinek könnyű vizsgát, garantált pontszámot vagy minden szakon elfogadott tárgyat. A kérdésfelvetés a jól felépített, feladattípusokon gyakorolható emelt felkészülésről szól. A felvételi elfogadás és az intézményi pontok szakonként ellenőrizendők.

Elsődleges források, ellenőrizve 2026-11-14:

- [Felvi: Érettségi százalékból pontok](https://www.felvi.hu/felveteli/pontszamitas/erettsegi_pontok): az intézmények szakonként határozzák meg a két érettségi tárgyat és a szükséges szintet.
- [Felvi: Pontszámítás 2027–2028](https://www.felvi.hu/felveteli/pontszamitas/pontszamitas_27_28): a célzott év, szak és intézmény követelményeinek keresője.
- Ellenőrizve november 15-én: a BGE [gazdaságtudományi](https://uni-bge.hu/hu/felveteli/erettsegi-vizsgatargyak-az-erettsegi-pont-szamitasahoz-gazdasagtudomanyok), [társadalomtudományi](https://uni-bge.hu/hu/felveteli/erettsegi-vizsgatargyak-az-erettsegi-pont-szamitasahoz-tarsadalomtudomanyok) és [informatikai](https://uni-bge.hu/hu/felveteli/erettsegi-vizsgatargyak-az-erettsegi-pont-szamitasahoz-informatika) listáin is szerepel a digitális kultúra. Ez a többféle továbbtanulási irányra utaló mondat alapja, nem minden szakra vagy későbbi évre szóló garancia.

## Ellenőrzés és kiadás

Az új budapesti dátumhatár, a hosszabbítás időszaka, a `validUntil` válasz és a teljes befizetés ellenőrzése backendtesztekkel lefedve. A tényleges teszteredmények és az éles kiadás: [DEPLOY-STATUS](DEPLOY-STATUS.md), [HANDOFF](HANDOFF.md). A jelentkezésnyitás kapcsolója marad engedélyezett; éles tesztjelentkezés ehhez a tartalmi módosításhoz nem szükséges.
