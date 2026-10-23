# Cloudflare DNS és Tunnel beállítási terv

**Állapot: 2026. október 22. — előkészítési útmutató, nem végrehajtott éles telepítés.** A cél egy Ubuntu alapú Rackforest VPS és a `diku-erettsegi.hu` domain összekötése. A domain a jelenlegi magyar regisztrátornál marad; csak az autoritatív DNS szolgáltatója változik Cloudflare-re. Domaintranszfer és regisztrátorváltás nem szükséges. A webes forgalom Cloudflare proxyn és Tunnelen érkezik.

A 2026. október 22-i, csak olvasási DNS-ellenőrzés eredménye:

| Rekord | Megfigyelt érték |
| --- | --- |
| NS | `ns1.m.glbns.com` |
| NS | `ns2.m.glbns.com` |
| MX | prioritás `5`, cél `mail.diku-erettsegi.hu` |

Ez nem teljes zónaexport. Az összes jelenlegi rekordot külön fel kell mérni. A Cloudflare által kiosztott új névszerverek és a Tunnel azonosítója még nincsenek rögzítve. Cloudflare-fiókhoz jelenleg nincs hozzáférés; az SSH-kapcsolat és a VPS olvasási felmérése sikerült, lásd [SERVER-AUDIT](SERVER-AUDIT-2026-10-22.md). Ez a dokumentum nem tartalmaz szerverjelszót, tokent vagy SSH-kulcsot. Nem történt DNS-módosítás vagy éles telepítés.

## 1. Hozzáférések és mentés

A végrehajtáshoz szükséges a regisztrátor DNS/névszerver/DNSSEC kezelési joga, a megfelelő Cloudflare-fiók és zóna kezelési joga, valamint a Rackforest VPS ellenőrzött SSH-hozzáférése. A domain tulajdonosa és a megújítás kezelése a regisztrátornál marad. A VPS telepítési és frissítési folyamata a [DEPLOYMENT.md](DEPLOYMENT.md) dokumentumban található.

Névszerverváltás előtt exportáld a teljes jelenlegi DNS-zónát, és őrizd meg hozzáférés-védett helyen a rekordokat, TTL-eket, régi névszervereket és DNSSEC/DS állapotot. Az automatikus Cloudflare-felderítés eredményét tételesen hasonlítsd össze ezzel; nem helyettesíti a teljes leltárt. A meglévő DNS-szolgáltatást az átállás ellenőrzéséig tartsd működésben. [Cloudflare teljes DNS-beállítás](https://developers.cloudflare.com/dns/zone-setups/full-setup/setup/).

Külön ellenőrizendő a levelezés:

- Minden mail kiszolgáló A/AAAA rekordja, az MX rekordok célja és prioritása.
- SPF TXT, valamennyi DKIM selector TXT/CNAME, `_dmarc` TXT, szolgáltatásellenőrző TXT rekordok.
- A használt `autodiscover`, `autoconfig`, webmail és más levelezési nevek, továbbá SRV rekordok, ha vannak.
- A mail kiszolgálóra mutató rekordok Cloudflare-nél **DNS only**, azaz szürke felhős állapotban legyenek. Az SMTP forgalom nem a webes Tunnelre kerül.

A meglévő értékeket a szolgáltató tényleges konfigurációjából vedd át; ne hozz létre kitalált SPF/DKIM/DMARC tartalmat vagy új levelezési szolgáltatást. Az apex címére támaszkodó SPF `a` mechanizmust külön vizsgáld meg, mert a webes DNS-cél későbbi cseréje módosíthatja a jelentését. A `mail.diku-erettsegi.hu` kiszolgáló címét nem szabad automatikusan a VPS-re átírni. [Cloudflare levelezési rekordok](https://developers.cloudflare.com/dns/manage-dns-records/how-to/email-records/).

## 2. Zóna létrehozása, DNSSEC és névszerverváltás

1. Add hozzá a `diku-erettsegi.hu` zónát a kiválasztott Cloudflare-fiókhoz teljes, autoritatív DNS-beállítással. Importáld és ellenőrizd a meglévő rekordokat. Az átállás előkészítése közben a régi webes cél is maradjon működőképes; a Tunnelre váltás külön lépés.
2. Jegyezd fel a **Cloudflare által ehhez a zónához ténylegesen kiosztott két névszervert**. Másik domain névszervere vagy példából másolt név nem használható.
3. Ellenőrizd, van-e DNSSEC és a `.hu` szülőzónában DS rekord. Ha van, a régi DS eltávolítását intézd a regisztrátornál még a névszerverváltás előtt. Várd meg és ellenőrizd a korábbi DS gyorsítótári élettartamának lejártát; addig a régi DNS aláírását ne szakítsd meg. A DNSSEC ki- és bekapcsolásának pontos kezelőfelületét a regisztrátornál kell azonosítani.
4. A regisztrátor **domain névszerver-beállításában** cseréld le a két régi névszervert a kiosztott Cloudflare-párra. Ez nem a régi zónába felvett két új NS rekord, és nem domaintranszfer. Kövesd a regisztrátor `.hu` delegálási ellenőrzéseit.
5. Várd meg a Cloudflare zóna aktív állapotát és a delegálás terjedését. Ellenőrizd több resolverrel az NS, MX és mail címrekordokat; az átállásnak nincs garantált azonnali befejezési ideje.
6. A stabil Cloudflare delegálás után engedélyezd a DNSSEC-et Cloudflare-nél, majd a **most kapott új DS-adatokat** add meg a regisztrátornál. Ellenőrizd a teljes hitelesítési láncot. A régi DNS-szolgáltató DS-értékét nem szabad visszamásolni az új zónához.

Források: [névszerverek frissítése](https://developers.cloudflare.com/dns/nameservers/update-nameservers/), [DNSSEC beállítása](https://developers.cloudflare.com/dns/dnssec/). A DNSSEC jelenlegi állapotáról ez az útmutató nem tesz feltételezést; azt a végrehajtáskor fel kell mérni.

## 3. Távolról kezelt Tunnel és a VPS

Az alkalmazás tervezett útvonala:

```text
Böngésző → Cloudflare HTTPS → titkosított Tunnel → cloudflared
                                                     ↓ Docker hálózat
                                                frontend:80
                                                     ↓ /api
                                                backend:8080 → db:3306
```

A Cloudflare felületén hozz létre egy **remotely managed** Tunnelt. A jelenlegi felületen ez a Networking → Tunnels területről érhető el. A publikus alkalmazás útvonalának beállítása:

| Beállítás | Érték |
| --- | --- |
| Nyilvános hostname | `diku-erettsegi.hu` |
| Útvonal | minden útvonal |
| Service URL / origin | `http://frontend:80` |
| Kapcsolat | a production Compose `cloudflared` konténere |

A `frontend` Docker szolgáltatásnév: a `cloudflared` és a frontend közös Docker hálózatán oldódik fel. Itt a `localhost:80` a Tunnel saját konténerét jelentené. A Tunnel által létrehozott webes DNS-rekordnál ellenőrizd az esetleges meglévő apex A/AAAA/CNAME ütközést; csak az érintett webes rekordokat cseréld, a levelezési rekordokat őrizd meg. A CNAME célját a tényleges Tunnel alapján a Cloudflare adja; ne írj be kitalált Tunnel UUID-t. [Tunnel létrehozása és alkalmazás közzététele](https://developers.cloudflare.com/tunnel/get-started/).

### Tokenfájl, Docker Compose secret

A projekt tervezett tokenátadása fájlos. A VPS `database` könyvtárához képest a `secrets/cloudflared-token` tartalmazza kizárólag a tényleges Tunnel tokent. A könyvtár és tartalma Gitből kizárt; ezt az első token elhelyezése előtt ellenőrizni kell. A Compose megfelelő részlete:

```yaml
services:
  cloudflared:
    command: tunnel --no-autoupdate --metrics 127.0.0.1:2000 run
    environment:
      TUNNEL_TOKEN_FILE: /run/secrets/cloudflared-token
    secrets:
      - cloudflared-token

secrets:
  cloudflared-token:
    file: ./secrets/cloudflared-token
```

Ez részlet a production Compose-hoz, önmagában nem teljes telepítési fájl. **`TUNNEL_TOKEN` környezeti változót nem használunk.** A rögzített image `65532:65532` felhasználója olvassa a secretet: a `secrets` szülőmappa 0700, a tokenfájl 0644 módú legyen. A szülőmappa tiltja más hostfelhasználók hozzáférését; a fájl olvashatóságát a konténerbe bind-mountolt secreten is biztosítani kell. A Compose secret nem váltja ki a host fájljogainak védelmét. A `preflight.sh` ellenőrzi ezt, a kész Compose a Tunnel kapcsolatát healthcheckkel figyeli.

A `TUNNEL_TOKEN_FILE` távolról kezelt Tunnelhez használható, cloudflared `2025.4.0` vagy újabb verzióval. Élesítés előtt kipróbált image-digestet rögzíts. A tokent ne másold dokumentumba, commitba, `.env.production` változóba, terminál-parancs argumentumába vagy naplóba. Rotáláskor a Cloudflare-nél cseréld, frissítsd a védett fájlt, és indítsd újra a connectort. [Hivatalos token-file futtatási paraméter](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/configure-tunnels/run-parameters/).

### Hálózat és tűzfal

A Rackforest szolgáltatói tűzfalán és az Ubuntu tűzfalán is engedni kell a Tunnel **kimenő 7844/UDP és 7844/TCP** kapcsolatát a Cloudflare dokumentált céljai felé. A QUIC UDP-t, a HTTP/2 TCP-t használ. A szerver DNS-feloldásának, HTTPS kimenő csomagletöltésének és image-pulljának szintén működnie kell. A célhálózatok listáját a beállításkor a hivatalos leírásból vedd át. [Tunnel tűzfal mögött](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/configure-tunnels/tunnel-with-firewall/).

Az alkalmazáshoz **nem kell bejövő 80/443 portot nyitni**, és a 8080/3306 portot sem publikáljuk. A production Compose frontendje belső szolgáltatás marad. Az SSH elérése külön üzemeltetési csatorna: maradjon a kialakított, korlátozott módon elérhető. A webes Tunnel létrehozása nem állít be automatikusan SSH-hozzáférést; a tűzfal módosítása előtt a meglévő hozzáférést és helyreállítási lehetőséget ellenőrizni kell.

## 4. HTTPS és www átirányítás

A Cloudflare edge tanúsítványa fedje le a `diku-erettsegi.hu` és `www.diku-erettsegi.hu` neveket, és legyen aktív. A meglévő CAA rekordokat vizsgáld meg, ha a tanúsítvány kiadása elakad. Kapcsold be a HTTPS-re terelést. A böngésző és Cloudflare között HTTPS, a VPS-ig titkosított Tunnel, a Docker hálózaton pedig a fenti HTTP origin működik.

A `www` névhez hozz létre proxizott DNS-rekordot, például az apexre mutató CNAME-et; a szabály csak Cloudflare-en átmenő kérésen fut. A Cloudflare Redirect Rule tervezett beállítása:

```text
Feltétel:       http.host eq "www.diku-erettsegi.hu"
Dinamikus cél:  concat("https://diku-erettsegi.hu", http.request.uri.path)
HTTP státusz:   301
Query string:  megőrzés bekapcsolva
```

Példa: `https://www.diku-erettsegi.hu/kurzusok?utm_source=teszt` eredménye `https://diku-erettsegi.hu/kurzusok?utm_source=teszt`. A www cím HTTPS-kézfogása az átirányítás előtt történik, ezért annak tanúsítványa is szükséges. [Cloudflare www → fődomain átirányítás](https://developers.cloudflare.com/rules/url-forwarding/examples/redirect-www-to-root/).

## 5. API és privát oldalak gyorsítótárazása

A projekt Cloudflare Cache Rule szabálya állítsa **Bypass cache** módba az API-t, a belépési és védett útvonalakat, valamint a session cookie-val érkező kéréseket. A feltétel tervezett alakja:

```text
(http.request.uri.path eq "/api") or
starts_with(http.request.uri.path, "/api/") or
(http.request.uri.path eq "/admin") or
starts_with(http.request.uri.path, "/admin/") or
(http.request.uri.path eq "/tanulo") or
starts_with(http.request.uri.path, "/tanulo/") or
(http.request.uri.path eq "/belepes") or
starts_with(http.request.uri.path, "/belepes/") or
(http.cookie contains "JSESSIONID=")
```

A szabályok sorrendjét úgy állítsd be, hogy későbbi cache-szabály ne írja felül ezt. A sessionnel védett fájlletöltés is az API része; nem kerülhet megosztott cache-be. Az origin `Cache-Control: no-store` fejléceit őrizd meg. A verziózott statikus assetek cache-elhetők; általános „Cache Everything” szabályt ne alkalmazz a privát tartalomra. [Cookie alapú cache-kivétel](https://developers.cloudflare.com/cache/how-to/cache-rules/examples/bypass-cache-on-cookie/).

## 6. Aktiválás utáni ellenőrzés és visszaállítás

A következők még végrehajtandó ellenőrzések, nem kész eredmények:

- A zóna aktív, a nyilvános NS a kiosztott Cloudflare-pár; az MX és valamennyi mail rekord megegyezik a jóváhagyott leltárral. A levelezés gazdája ellenőrizze a tényleges küldést és fogadást is.
- A DNSSEC az új Cloudflare DS-adattal validál, nincs `SERVFAIL`.
- A Tunnel `Healthy`, az apex HTTPS-en ténylegesen betölt; a www 301 megőrzi az útvonalat és query stringet. A konténer healthcheck önmagában nem igazolja ezeket.
- Belépés, CSRF, admin/tanuló jogosultság és védett letöltés a publikus HTTPS címen is működik; a session cookie `Secure` és `HttpOnly`. Az API és privát válaszok nem érkeznek megosztott cache-ből.
- Nincs közvetlen publikus alkalmazás- vagy adatbázisport; a szükséges SSH-hozzáférés működik. Token nincs Gitben, dokumentumban vagy naplóban.
- A [deployment ellenőrzési lista](DEPLOYMENT.md) mentési, visszaállítási és automatikus frissítési próbái is elkészültek. A jelentkezési űrlap éles megnyitásának külön feltétele a végleges jogi és adatkezelési tartalom.

Hiba esetén először a konkrét rekordot, Tunnel route-ot vagy szabályt javítsd a mentett állapot alapján. Teljes DNS-visszaállásnál a régi zónának továbbra is rendelkezésre kell állnia, és a delegálással együtt a DNSSEC/DS láncot is összehangoltan kell visszaállítani. A cache-ek miatt ez sem azonnali. A régi DNS-szolgáltatást csak a stabil működés és a levelezés ellenőrzése után lehet kivezetni.
