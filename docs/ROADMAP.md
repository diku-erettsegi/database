# Célok és következő lépések

Frissítve: 2026-10-22. A [stratégia](STRATEGY-2026-10.md) irányadó: összevont kedvezmény maximum 35%-ig, kézi levelezés, stockfotók. Az aktuális kérés az automatikus Rackforest deploy előkészítése; teszt- és futtatási eredmények a HANDOFF.md-ben.

## 1. Helyi alkalmazás – elkészült alap

- React publikus oldalak stockfotókkal, rövid jóváhagyott tartalommal és a megmaradt hiányok jelölésével, mobil navigáció.
- 18 útvonal + külön 404 statikus HTML-lel, egyedi metaadatokkal, H1-gyel, sitemappel és canonicallel.
- Két 24 fős csoport, kiválasztás, szerveroldali ár-pillanatkép/időpont, maximum 35% kedvezmény, barát és laptop adatok, idempotens jelentkezés.
- Admin csoportszűrés, tranzakciós férőhelykezelés, változatlan régi rekordok és árak.
- Programozós érdeklődők tartós mentése és kézi státusz/megjegyzés kezelése; automatikus e-mail nélkül.
- Szülői és diák tájékoztató, hivatalos OH feladatsor-linkgyűjtemény, opcionális noindex ízelítő.
- Session belépés, admin userkezelés és eseménynapló.
- Órák létrehozása/szerkesztése, dátum, meetinglink, publikálás, fájlok; egyszerű tanulói olvasás/letöltés.
- Dockerrel futtatható teljes környezet, V1–V3 Flyway migráció, dokumentált API/architektúra/döntések és releváns ellenőrzések.

Az ellenőrzések konkrét eredménye a HANDOFF.md-ben van. A cél helyben működő alap; az éles szolgáltatás nem része ennek a lépésnek.

## 2. Üzleti tartalom és próbaüzem

Az oktatók neve, helyszín intézménye, alapár/kedvezmények, kezdés és óraszám már ismert. Következő feladat a részletes húszalkalmas naptár, fizetési/lemondási feltételek, baráti jogosultság kézi ellenőrzése, laptopbérlés, valódi portrék, pontos terem, telefonszám és jogi tájékoztatók véglegesítése. A naptárt az ünnepekhez és a célzott érettségihez kell igazítani.

Adminok próbálják végig a jelentkezés→kapcsolatfelvétel→elfogadás→fiók→publikált óra és az érdeklődő→kézi megkeresés→lezárás folyamatot. Valódi tananyagokkal fájlméret/formátum ellenőrzés, mobil és akadálymentességi próba szükséges. Szövegváltozásokat a frontendben, nem a backend DTO-kban kell kezelni. Automatikus e-mail vagy SMTP beállítása nem része ennek az ütemnek.

## 3. VPS és automatikus üzem

Rackforest Ubuntu: az SSH-felmérés kész, a konkrét [telepítési](DEPLOYMENT.md) és [DNS/Tunnel](CLOUDFLARE-SETUP.md) terv dokumentált. Preflight, megszakítást kezelő deploy, mentés és korlátozott újrapróbálkozású napi timer előkészítve. Hátravan az első GitHub push, Docker/Compose/GHCR/Tunnel beállítás, első éles admin és a timerek aktiválása. Mentés→restore gyakorlat, hibás image valódi staging próbája, külső backup/monitorozás és végleges tartalom is kell. Infrastrukturális main változások felügyeltek; az alkalmazásimage-ek az aktiválás után automatikusan frissülnek.

## 4. Igény alapján bővítés

Tananyag-hozzáférést szabályozó csoporttagság/évfolyam; fiókátadási és jelszóhelyreállítási folyamat; audit/lista lapozás, keresés/export/törlés; admin beállítások/marketing CMS; object storage; többpéldányos session. Ezek nem kész funkciók, prioritásukat valódi használat alapján kell eldönteni. A levelezés jelenleg tudatosan kézi; automatizálásához új termékdöntés kell. Online fizetés, teljes LMS és videóhosting nem szükséges az induló célhoz.
