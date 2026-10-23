# Rackforest VPS – olvasási felmérés, 2026-10-22

A felhasználó által helyben megadott SSH-hozzáféréssel sikeres kapcsolat és kizárólag olvasási ellenőrzés történt. Csomagot, felhasználót, tűzfalat, SSH-beállítást, alkalmazást és DNS-t nem módosítottunk. Ez állapotfelmérés, nem biztonsági audit vagy terheléses próba.

| Tétel | Megfigyelt állapot |
| --- | --- |
| Operációs rendszer | Ubuntu 24.04.5 LTS, Noble |
| Architektúra / CPU | x86_64, 1 vCPU |
| RAM | 3916 MB összesen, a méréskor 3534 MB elérhető |
| Swap | 2047 MB, a méréskor használaton kívül |
| Root fájlrendszer | 30 GB; 5,7 GB használt, 23 GB szabad |
| Docker / Compose | Nincs telepítve |
| `/opt` | Üres |
| Publikusan figyelő TCP port | SSH 22, IPv4 és IPv6 |
| DNS resolver | Csak loopback címeken |
| UFW | Nincs telepítve; ez nem bizonyítja minden host/szolgáltatói tűzfal hiányát |
| SSH | root belépés, jelszó és publikus kulcs engedélyezett |
| Idő | Europe/Budapest, NTP szinkronizált |
| Reboot-required jelző | Nem volt jelen |

Az első SSH-kapcsolat szerverkulcsát helyben rögzítettük a Gitből kizárt `database/.deploy/ssh_known_hosts` fájlba. A legelső kulcs elfogadása trust-on-first-use volt, nem Rackforest konzolból függetlenül hitelesített egyezés. Későbbi eltérést nem szabad automatikusan felülírni; szolgáltatói konzolon ellenőrizendő.

IP-cím, jelszó és token nincs ebben a repóban. A gyökérmappa `secret.txt` fájlját ne másold egyik Git repóba sem. A belépési adatot jelszókezelőben kell őrizni; a helyi átadási fájl sorsáról a tulajdonos dönt. A Git-kizárás nem helyettesíti a hozzáférés-védelmet.

Következő lépés a [telepítési útmutató](DEPLOYMENT.md) egyszeri előkészítése. Az 1 vCPU miatt minden build GitHubon történjen. A memória kezdeti kis terheléshez használható becslés, a feltöltések, image-ek és mentések tárhelyigényét együtt kell figyelni. Root/jelszavas SSH szigorítása csak kipróbált kulcsos operátor és elérhető helyreállítási konzol mellett történhet.
