# SEO és tartalom

Állapot: 2026-10-21. Az útvonalak és metaadatok forrása a frontend `src/seo.ts`; a build és ellenőrzések tényleges eredménye a [HANDOFF](HANDOFF.md) fájlban van.

## Technikai szerződés

- A React build 18 ismert útvonalhoz és külön 404-hez állít elő HTML-t. A publikus szöveg/H1 és metaadat JavaScript nélkül is olvasható; a csoportkártyák élő árát/férőhelyét az API frissíti. A beküldés és belépés JavaScriptet igényel.
- Oldalanként egyedi title, description és egy H1. Canonical host `https://diku-erettsegi.hu`, aloldalak záró perjel nélkül. Magyar nyelvkód és Open Graph title/description/url/locale.
- `WebSite` és `BreadcrumbList` JSON-LD; nincs kitalált értékelés vagy saját tanteremként feltüntetett stockfotó. A megadott valós kurzusadat később további sémát alapozhat meg, de a jelenlegi kód nem állít elő dinamikus `Offer` árat.
- A generált sitemap csak indexelhető route-ot tartalmaz. A noindex shelloldalak olvashatók a robot számára; a `/api/` robots tiltást kap. A robots/noindex nem hozzáférésvédelem.
- Nginx valódi HTTP 404-et ad ismeretlen útvonalon, relatív 301-et a záró perjeles/index.html változatokra. Hash-elt asset hosszú cache, HTML újraellenőrzés, API no-store.
- Helyi betűfájlok és optimalizált stockfotó WebP-k, képméretek/alt szövegek, indokolt lazy loading, gzip és reduced-motion. Követőkód és külső térkép nincs.

Új oldalnál a route-regiszter, komponens, Nginx szabály és SEO tesztlista együtt változzon. A meta keywords tag nem része a tervnek: szemantikus címsorok, jól címkézett linkek és releváns metaadatok szükségesek. Kulcsszóhalmozás vagy ismételt marketingbekezdés helyett rövid, oldalhoz illő tartalom kell.

## Oldalak és keresési szándék

| URL | Cél / indexelés |
| --- | --- |
| `/` | Budapesti, tantermi emelt digitális kultúra felkészítő |
| `/kurzusok` | Délelőtti/délutáni kurzusválasztás és jelentkezés |
| `/jelentkezes` | Megőrzött jelentkezési útvonal, saját title/H1/canonical |
| `/szuloknek` | Szülői döntési kérdések |
| `/diakoknak` | Tanulási folyamat, eszközök, gyakorlat |
| `/oktatas-menete` | Tematika, órák felépítése, próbaérettségi |
| `/oktatok` | Balázs és Peti bemutatkozása |
| `/arak` | 280 000 Ft alapdíj, korai/baráti kedvezmény, maximum 35% |
| `/helyszin` | Gábor Dénes Egyetem, Budapest XI. kerület |
| `/gyik`, `/kapcsolat` | Rövid válaszok és kapcsolatfelvétel |
| `/erettsegi-feladatsorok` | Hivatalos emelt digitális kultúra PDF/ZIP gyűjtemény |
| `/programozas-izelito` | Noindex oktatópélda kézi megosztáshoz |
| `/adatkezeles`, `/impresszum` | Noindex jogi piszkozat |
| `/belepes`, `/tanulo`, `/admin` | Noindex belépési/védett felület |
| Ismeretlen URL | 404, noindex |

A `/kurzusok` és `/jelentkezes` funkciója közös, jelenleg mindkettő saját canonicalt kap. Éles forgalom alapján később dönthető el az összevonás/átirányítás; ne törjük el a régi jelentkezési hivatkozást hallgatólagosan.

A feladatsorokhoz a frontend `src/examSources.ts` verziózza az OH eredeti linkjeit és az ellenőrzési adatot. A látogató lássa az évet, időszakot, szintet és fájltípust. Saját tárhelyes másolat, hivatalos partneri állítás és automatikus helyezési ígéret nincs.

## Éles indulás előtt

Véglegesítendők a jogi oldalak, portrék, terem, telefon és részletes naptár. A hiányos oldalak indexelését ennek alapján felül kell vizsgálni. A stockfotóhoz maradjon forrás/licencnyom: [IMAGE-ASSETS](IMAGE-ASSETS.md).

A valós domainen ellenőrizendő a HTTPS, www→apex átirányítás, canonical, valódi 404, robots/sitemap, mobil navigáció és teljesítmény. A Search Console tulajdonigazolás/sitemap beküldés későbbi üzemeltetői feladat. Az időszakos árakat, éveket és vizsgalinkeket tartalmi karbantartáskor együtt kell frissíteni; a kliens dátuma nem dönthet a mentett kedvezményről.

Hivatalos háttér: [Google JavaScript SEO](https://developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics), [canonical URL-ek](https://developers.google.com/search/docs/crawling-indexing/consolidate-duplicate-urls). A technikai alap nem garantál keresési helyezést.