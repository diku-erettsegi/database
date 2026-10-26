# Cloudflare DNS és Tunnel beállítási útmutató

## Levelezési DNS beállítva – 2026. október 25., 22:42 CET

A felhasználó által átadott kulcs és szolgáltatói képernyőkép alapján a következő két rekord létrejött a meglévő Cloudflare-zónában:

| Név | Típus | Érték | TTL |
| --- | --- | --- | --- |
| `default._domainkey` | TXT, DNS only | A kapott `v=DKIM1; k=rsa; p=...` nyilvános kulcs, pontos másolat | 3600 s |
| `_dmarc` | TXT, DNS only | `v=DMARC1;p=none` | 3600 s |

A nyilvános kulcs helyi forrása a Gitből kizárt `secrets/dkim-record.txt`; RSA 2048 bit, a dekódolt DER SHA-256 ujjlenyomata `30852beef4b55462d436afa33218d92dfb22fb812fff48e7a77d937776fcd9e6`. A Cloudflare automatikusan több TXT-karakterláncra bontja a hosszú értéket; ezek összefűzve adják az eredeti rekordot. A szolgáltatói zónaexportban látható `\;` escape nem került szó szerinti backslashként a rekordba. A DKIM privát kulcsa a levelezőszolgáltatónál marad.

Igazolás: a Cloudflare felületén mindkét rekord visszaolvasva; `alexa.ns.cloudflare.com` és `gerardo.ns.cloudflare.com` közvetlen TXT-válasza tartalmazza őket. Google és Cloudflare DoH-n a DKIM teljes tartalma egyezik a bemásolt kulccsal; Cloudflare DoH-n a DMARC is egyezik. Google DoH-n a DMARC 21:42:44 UTC-kor még negatív cache-ben volt, 1494 s hátralévő TTL-lel. A változatlan MX `5 mail.diku-erettsegi.hu`, mail A `185.111.89.212` és SPF `v=spf1 ip4:185.111.89.212 ~all` mindkét resolverrel ellenőrzött. Ez a szakasz felülírja az alábbi történeti levelezési állapotot.

A `p=none` nem kér DMARC-alapú karantént vagy elutasítást. Riportcím (`rua`) nem volt megadva, ezért nem került be; a rekord önmagában nem hoz létre riportgyűjtést. Következő ellenőrzés: a szokásos levelezőből saját külső postaládába küldött levél `Authentication-Results` fejlécében DKIM/SPF/DMARC eredmény és domainilleszkedés, valamint fogadási próba. Levélküldés vagy küldőszerver-konfiguráció ellenőrzése még nem történt; a DNS-kulcs publikálása önmagában nem igazolja a levelek aláírását. `quarantine`/`reject` házirendre csak a tényleges küldők ellenőrzése után válts. Az alkalmazás továbbra sem küld automatikus e-mailt.

Források: [Cloudflare levelezési rekordok](https://developers.cloudflare.com/dns/manage-dns-records/how-to/email-records/), [cPanel Email Deliverability](https://docs.cpanel.net/cpanel/email/email-deliverability-in-cpanel/). Helyi képernyőkép és DNS-ellenőrzések: `.deploy/cloudflare-dkim-dmarc-20261025.png`, `.deploy/dkim-verification-20261025.json`, `.deploy/dkim-authoritative-20261025.json`, `.deploy/dmarc-google-recheck-20261025.json` (Gitből kizárva).

## Korábbi webes DNS- és Tunnel-ellenőrzések

**Legfrissebb ellenőrzés: 2026. október 25.** A Microware névszerverváltás már igazolt a `.hu` szülőzónából, Google és Cloudflare DNS-ből. A Cloudflare felület még pending; kézi névszerver-ellenőrzés elindítva. DS nincs, apex/www Proxied beállítás megőrizve, négy VPS-konténer healthy, publikus HTTPS még nem működik. A korábbi halasztás történeti állapot: **a regisztrátori váltást nem kell újra elvégezni**, az aktiválást és HTTPS-t kell ellenőrizni. Részletek: [DEPLOY-STATUS](DEPLOY-STATUS.md).

**Állapot: 2026. október 24.** A Rackforest VPS-en négy konténer healthy, mindkét alkalmazás automatikus frissítése, a belső auth/restore és a backup systemd szolgáltatás próbája sikeres; a két timer enabled/active. A Cloudflare Free zóna, Tunnel route, www 301, HTTPS-beállítások és privát/API cache bypass elkészült, a zóna **Pending Nameserver Update**. A felhasználó a Microware névszerverváltást későbbre halasztotta: **most kihagyjuk, a publikus domain/HTTPS próbával együtt**. A VPS működése és a domain nyilvános aktiválása külön állapot. Részletes igazolások és korlátok: [DEPLOY-STATUS](DEPLOY-STATUS.md).

A `diku-erettsegi.hu` domain Microware-nél marad; csak az autoritatív DNS szolgáltatója változik majd Cloudflare-re. Domaintranszfer és regisztrátorváltás nem szükséges. A tervezett webes útvonal Cloudflare proxy és Tunnel. Az alábbi eljárás a későbbi aktiválás és új környezetek útmutatója; a már kész zónát, Tunnelt és tokenfájlt ne hozd létre újra.

A 2026. október 22-i, csak olvasási DNS-ellenőrzés eredménye:

| Rekord | Megfigyelt érték |
| --- | --- |
| NS | `ns1.m.glbns.com` |
| NS | `ns2.m.glbns.com` |
| MX | prioritás `5`, cél `mail.diku-erettsegi.hu` |

Ez történeti DNS-pillanatkép, nem teljes zónaexport. Az október 24-i Cloudflare-beállítások a felületen visszaolvasva:

| Beállítás | Jelenlegi konfiguráció |
| --- | --- |
| Kiosztott új NS | `alexa.ns.cloudflare.com`, `gerardo.ns.cloudflare.com` |
| Tunnel | `diku-erettsegi`, connector healthy |
| Publikus route | `diku-erettsegi.hu` → `http://frontend:80` |
| Apex DNS | proxizott CNAME a tényleges Tunnelre |
| www DNS | proxizott CNAME az apexre |
| mail A és wildcard A | korábbi tárhelycél, DNS only |
| MX | prioritás `5`, cél `mail.diku-erettsegi.hu`, megőrizve |
| www → apex átirányítás | 301, útvonal és query megőrzése, szabály mentve |
| HTTPS | Always Use HTTPS bekapcsolva, minimum TLS 1.2; edge tanúsítvány még nincs |
| Privát/API cache | `DIKU private and API bypass`, Active |

A névszerverek kiosztása nem jelenti a Microware delegálás módosítását. A felhasználó legfrissebb közlése szerint nincs használt levelezés vagy aldomain, a levelezést később maga intézi. A meglévő mail/MX/wildcard rekordokat megőriztük. Cloudflare-konfiguráció és VPS-telepítés történt, a nyilvános domainváltás még nincs végrehajtottként igazolva. Szerverjelszó, token és SSH-kulcs ebben a dokumentumban nincs.

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

**A mostani projektben az 1–2. lépés kész. A regisztrátori váltást a felhasználó későbbre halasztotta; az alábbi további lépéseket most ne hajtsd végre.** A kiosztott névszerverpár a fenti táblában szerepel.

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

A jelenlegi **remotely managed** Tunnel már létrejött `diku-erettsegi` néven, a connector healthy, az alábbi route mentve. Új környezetben a Networking → Tunnels területen hozható létre. A publikus alkalmazás beállítása:

| Beállítás | Érték |
| --- | --- |
| Nyilvános hostname | `diku-erettsegi.hu` |
| Útvonal | minden útvonal |
| Service URL / origin | `http://frontend:80` |
| Kapcsolat | a production Compose `cloudflared` konténere |

A `frontend` Docker szolgáltatásnév: a `cloudflared` és a frontend közös Docker hálózatán oldódik fel. Itt a `localhost:80` a Tunnel saját konténerét jelentené. A Tunnel által létrehozott webes DNS-rekordnál ellenőrizd az esetleges meglévő apex A/AAAA/CNAME ütközést; csak az érintett webes rekordokat cseréld, a levelezési rekordokat őrizd meg. A CNAME célját a tényleges Tunnel alapján a Cloudflare adja; ne írj be kitalált Tunnel UUID-t. [Tunnel létrehozása és alkalmazás közzététele](https://developers.cloudflare.com/tunnel/get-started/).

### Tokenfájl, Docker Compose secret

A projekt tokenátadása fájlos, a valódi VPS-en működik és a preflight ellenőrizte. A VPS `database` könyvtárához képest a `secrets/cloudflared-token` tartalmazza kizárólag a tényleges Tunnel tokent. A könyvtár és tartalma Gitből kizárt; ezt új környezetben is az első token elhelyezése előtt ellenőrizni kell. A Compose megfelelő részlete:

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

A `TUNNEL_TOKEN_FILE` távolról kezelt Tunnelhez használható, cloudflared `2025.4.0` vagy újabb verzióval. A projekt cloudflared image-digestje rögzített, a jelenlegi verzió VPS-kapcsolata ellenőrzött; frissítéskor ismét tesztelj. A tokent ne másold dokumentumba, commitba, `.env.production` változóba, terminál-parancs argumentumába vagy naplóba. Rotáláskor a Cloudflare-nél cseréld, frissítsd a védett fájlt, és indítsd újra a connectort. [Hivatalos token-file futtatási paraméter](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/configure-tunnels/run-parameters/).

### Hálózat és tűzfal

A Rackforest szolgáltatói tűzfalán és az Ubuntu tűzfalán is engedni kell a Tunnel **kimenő 7844/UDP és 7844/TCP** kapcsolatát a Cloudflare dokumentált céljai felé. A QUIC UDP-t, a HTTP/2 TCP-t használ. A szerver DNS-feloldásának, HTTPS kimenő csomagletöltésének és image-pulljának szintén működnie kell. A célhálózatok listáját a beállításkor a hivatalos leírásból vedd át. [Tunnel tűzfal mögött](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/configure-tunnels/tunnel-with-firewall/).

Az alkalmazáshoz **nem kell bejövő 80/443 portot nyitni**, és a 8080/3306 portot sem publikáljuk. A production Compose frontendje belső szolgáltatás marad. Az SSH elérése külön üzemeltetési csatorna: maradjon a kialakított, korlátozott módon elérhető. A webes Tunnel létrehozása nem állít be automatikusan SSH-hozzáférést; a tűzfal módosítása előtt a meglévő hozzáférést és helyreállítási lehetőséget ellenőrizni kell.

## 4. HTTPS és www átirányítás

Az Always Use HTTPS már bekapcsolva, a minimum TLS-verzió 1.2. Edge tanúsítvány a pending NS miatt még nincs; a későbbi aktiváláskor fedje le a `diku-erettsegi.hu` és `www.diku-erettsegi.hu` neveket, és legyen aktív. A meglévő CAA rekordokat vizsgáld meg, ha a tanúsítvány kiadása elakad. A böngésző és Cloudflare között HTTPS, a VPS-ig titkosított Tunnel, a Docker hálózaton pedig a fenti HTTP origin a tervezett teljes útvonal.

A `www` névhez az apexre mutató proxizott CNAME és az alábbi külön Redirect Rule már elkészült. A szabály csak Cloudflare-en átmenő kérésen fut; a mentett konfiguráció működését a későbbi publikus aktiváláskor kell igazolni:

```text
Feltétel:       http.host eq "www.diku-erettsegi.hu"
Dinamikus cél:  concat("https://diku-erettsegi.hu", http.request.uri.path)
HTTP státusz:   301
Query string:  megőrzés bekapcsolva
```

Példa: `https://www.diku-erettsegi.hu/kurzusok?utm_source=teszt` eredménye `https://diku-erettsegi.hu/kurzusok?utm_source=teszt`. A www cím HTTPS-kézfogása az átirányítás előtt történik, ezért annak tanúsítványa is szükséges. [Cloudflare www → fődomain átirányítás](https://developers.cloudflare.com/rules/url-forwarding/examples/redirect-www-to-root/).

## 5. API és privát oldalak gyorsítótárazása

A **DIKU private and API bypass** Cache Rule **Active** állapotban mentve. A `/api`, `/admin`, `/tanulo`, `/belepes` útvonalprefixek vagy JSESSIONID cookie esetén **Bypass cache** a művelet. A beállítás a felületen kész, a külső működési próba a későbbi domainváltás után következik. A feltétel alakja:

```text
starts_with(http.request.uri.path, "/api") or
starts_with(http.request.uri.path, "/admin") or
starts_with(http.request.uri.path, "/tanulo") or
starts_with(http.request.uri.path, "/belepes") or
(http.cookie contains "JSESSIONID=")
```

A szabályok sorrendjét úgy állítsd be, hogy későbbi cache-szabály ne írja felül ezt. A sessionnel védett fájlletöltés is az API része; nem kerülhet megosztott cache-be. Az origin `Cache-Control: no-store` fejléceit őrizd meg. A verziózott statikus assetek cache-elhetők; általános „Cache Everything” szabályt ne alkalmazz a privát tartalomra. [Cookie alapú cache-kivétel](https://developers.cloudflare.com/cache/how-to/cache-rules/examples/bypass-cache-on-cookie/).

## 6. Aktiválás utáni ellenőrzés és visszaállítás

A publikus DNS/HTTPS ellenőrzések a felhasználó kérésére a későbbi névszerverváltás utánra maradnak. A connector és a négy VPS-konténer healthy állapota már igazolt; az alábbi teljes működési ellenőrzést ez nem helyettesíti:

- A zóna aktív, a nyilvános NS a kiosztott Cloudflare-pár; az MX és valamennyi megőrzött mail rekord megegyezik a jóváhagyott leltárral. Jelenleg nincs használt levelezés; későbbi bevezetésekor a felhasználó külön ellenőrizze a küldést és fogadást.
- A DNSSEC az új Cloudflare DS-adattal validál, nincs `SERVFAIL`.
- A Tunnel `Healthy`, az apex HTTPS-en ténylegesen betölt; a www 301 megőrzi az útvonalat és query stringet. A konténer healthcheck önmagában nem igazolja ezeket.
- Belépés, CSRF, admin/tanuló jogosultság és védett letöltés a publikus HTTPS címen is működik; a session cookie `Secure` és `HttpOnly`. Az API és privát válaszok nem érkeznek megosztott cache-ből.
- Nincs közvetlen publikus alkalmazás- vagy adatbázisport; a szükséges SSH-hozzáférés működik. Token nincs Gitben, dokumentumban vagy naplóban.
- A [deployment ellenőrzési lista](DEPLOYMENT.md) mentési, visszaállítási és automatikus frissítési próbái is elkészültek. A jelentkezési űrlap éles megnyitásának külön feltétele a végleges jogi és adatkezelési tartalom.

Hiba esetén először a konkrét rekordot, Tunnel route-ot vagy szabályt javítsd a mentett állapot alapján. Teljes DNS-visszaállásnál a régi zónának továbbra is rendelkezésre kell állnia, és a delegálással együtt a DNSSEC/DS láncot is összehangoltan kell visszaállítani. A cache-ek miatt ez sem azonnali. A régi DNS-szolgáltatást csak a stabil működés és a levelezés ellenőrzése után lehet kivezetni.
