# Telepítési állapot – 2026-10-23

A felhasználó kifejezetten kérte a tényleges deploy folytatását. Ez a fájl az aktuális állapot; az október 22-i szerverfelmérés történeti pillanatkép.

## Végrehajtva

- SSH-hozzáférés újra ellenőrizve, a korábban rögzített hostkey megőrzésével.
- Ubuntu 24.04 VPS: Docker Engine 29.9.2 és Compose v5.6.1 telepítve a Docker hivatalos apt-tárolójából; Docker indul rendszerindításkor.
- `diku-deploy` jelszavas belépés nélküli felhasználó, Docker-csoporttagság, `/opt/diku` saját könyvtár. Az SSH és a tűzfal konfigurációját nem módosítottuk.
- Frontend és backend első commitja a meglévő nyilvános GitHub-repók main ágára pusholva; a GitHub Actions elindult. Commitok: frontend `27c7d2e764a08c3047de8d70ebb4572a69c3f4c0`, backend `9c4e758b3cea10d86235219d751b085942f84c59`.
- A feltöltés előtt a staged fájlokat a tényleges SSH-titokra/címre és credential mintákra ellenőriztük; találat nem volt. Titok nem került Gitbe.
- A valódi Compose v5.1.3 által generált production JSON-t a Linux preflight fiktív envvel/tokenfájllal elfogadta. Ez konfigurációs integráció, nem futó production rendszer tesztje.

## Még folyamatban / szükséges

- Első CI-futások befejezése és GHCR image-ek tényleges lehúzása.
- Infra-repo első push/clone és production konfiguráció.
- A felhasználó jelezte, hogy még nincs Cloudflare-beállítás. A bejelentkezési oldal megnyitva, a saját fiók hitelesítése/feltételeinek elfogadása a felhasználónál.
- Cloudflare-zóna, Tunnel és token; teljes DNS-leltár, regisztrátori névszerverváltás, meglévő levelezés megőrzése.
- Első teljes deploy/health, admin beállítás és HTTPS ellenőrzés, timerek aktiválása.
- Külső mentési cél/megőrzés/riasztás és ellenőrzött restore-próba.

A nyilvános weboldal és az automatikus frissítés még nem aktív. Jelszó/token/IP nem szerepel ebben a dokumentumban. A telepítési eljárás: [DEPLOYMENT](DEPLOYMENT.md).
