# Közös infrastruktúra és dokumentáció

- A három mappa külön Git repó, a szülő könyvtár nem repó. Ne csinálj új monorepót.
- Belépési pont: README.md és docs/HANDOFF.md; tervek: docs/ARCHITECTURE.md, DECISIONS.md, PRODUCT.md, ROADMAP.md.
- Ez a repó a Compose, mentés, későbbi VPS deployment és közös dokumentáció helye. SQL séma csak a backend Flyway alatt él.
- A local Compose kizárólag loopbackre köt. Productionben nincs hostra publikált alkalmazás- vagy DB-port, a Cloudflare Tunnel az ingress.
- Ne commitolj .env, .env.production, backup, upload, token, éles log vagy személyes adat fájlt.
- Ne használj down -v parancsot normál frissítéshez. A volume-ok adatot őriznek.
- A deploy előkészítése és SSH-s felmérés az október 22-i kérés része; állapot: docs/DEPLOYMENT.md és SERVER-AUDIT-2026-10-22.md. Éles automatizálás még nem aktív; későbbi felhasználói utasítás szerint folytasd a dokumentált aktiválást.
- Deploy változáskor config ellenőrzés, Bash szintaxis, tests/preflight.test.sh és tests/deploy.test.sh; API integrációhoz scripts/smoke-test.mjs. A smoke helyi tesztadatot hagy maga után, ezt dokumentáld.
- Az ellenőrzött tényt és a tervezett jövőbeli működést külön jelöld. Minden változás végén aktualizáld az átadást és a korlátokat.
