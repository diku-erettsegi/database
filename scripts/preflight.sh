#!/usr/bin/env bash
# Read-only Ubuntu production checks. Never source env files or print Compose JSON.
set +x
set -Eeuo pipefail

fail() { printf 'FAIL: [%s] %s\n' "$1" "$2" >&2; exit 1; }
[[ $# -eq 0 ]] || fail USAGE 'Futtatás: bash scripts/preflight.sh (argumentum nélkül).'
[[ $(uname -s 2>/dev/null) == Linux ]] || fail PLATFORM 'Az ellenőrzés Linux környezetet igényel.'
for tool in docker python3; do
  command -v "$tool" >/dev/null 2>&1 || fail TOOLS 'Docker, Docker Compose plugin és Python 3 szükséges.'
done
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"
docker_cmd() {
  env -u BACKEND_IMAGE -u FRONTEND_IMAGE -u COMPOSE_PROJECT_NAME docker "$@"
}

# The program is static; only the non-secret checkout path is passed as an argument.
# -I ignores Python startup/path environment, -B prevents bytecode writes.
python3 -I -B - "$ROOT" 2>/dev/null <<'PY' || exit 1
import pathlib
import re
import stat
import sys

def fail(code, message):
    print(f"FAIL: [{code}] {message}", file=sys.stdout)
    raise SystemExit(1)

try:
    root = pathlib.Path(sys.argv[1])
    env = root / ".env.production"
    if env.is_symlink() or not env.is_file():
        fail("ENV_MISSING", "A .env.production szabályos, nem szimbolikus fájl legyen.")
    if stat.S_IMODE(env.stat().st_mode) != 0o600:
        fail("ENV_MODE", "A .env.production jogosultsága pontosan 0600 legyen.")
    active = [line.strip() for line in env.read_text(encoding="utf-8-sig").splitlines()
              if line.strip() and not line.lstrip().startswith("#")]
    if not active:
        fail("ENV_EMPTY", "A .env.production nem lehet üres.")
    if any("CHANGE_ME" in line.upper() for line in active):
        fail("ENV_PLACEHOLDER", "A production környezet még helyőrző értéket tartalmaz.")
    if any(re.match(r"(?:export\s+)?TUNNEL_TOKEN\s*=", line, re.I) for line in active):
        fail("TOKEN_ENV", "A tunnel token külön fájlba kerüljön, ne környezeti változóba.")

    secret_dir = root / "secrets"
    if secret_dir.is_symlink() or not secret_dir.is_dir():
        fail("SECRETS_MISSING", "A secrets könyvtár szükséges; szimbolikus link nem használható.")
    if stat.S_IMODE(secret_dir.stat().st_mode) != 0o700:
        fail("SECRETS_MODE", "A secrets könyvtár jogosultsága pontosan 0700 legyen.")
    token = secret_dir / "cloudflared-token"
    if token.is_symlink() or not token.is_file():
        fail("TOKEN_MISSING", "A secrets/cloudflared-token szabályos fájl szükséges.")
    info = token.stat()
    mode = stat.S_IMODE(info.st_mode)
    if mode & 0o7022:
        fail("TOKEN_MODE", "A tokenfájl nem lehet group/other írható vagy speciális jogosultságú.")
    # Compose local file secrets are bind mounts: uid/gid/mode settings do not
    # rewrite host ownership. UID/GID 65532 must really be able to read the file.
    # 0644 is intentional here: the host parent is private (0700).
    readable = bool(mode & (0o400 if info.st_uid == 65532 else 0o040 if info.st_gid == 65532 else 0o004))
    if not readable:
        fail("TOKEN_READABILITY", "A tokenfájl nem olvasható a cloudflared 65532 felhasználójának.")
    value = token.read_text(encoding="utf-8").strip()
    if not value:
        fail("TOKEN_EMPTY", "A tunnel tokenfájl üres.")
    placeholder = re.search(r"CHANGE[_ -]?ME|PLACEHOLDER|YOUR[_ -]?(?:TUNNEL[_ -]?)?TOKEN|REPLACE[_ -]?ME", value, re.I)
    if placeholder or value.lower() == "todo" or value.startswith("<") or value.endswith(">"):
        fail("TOKEN_PLACEHOLDER", "A tunnel tokenfájl még helyőrzőt tartalmaz.")
    if any(char.isspace() for char in value):
        fail("TOKEN_FORMAT", "A token egyetlen, belső szóköz nélküli érték legyen.")
except SystemExit:
    raise
except Exception:
    fail("FILES", "A production fájlok olvasása vagy ellenőrzése sikertelen; tartalmuk nem kerül naplóba.")
PY

docker_cmd compose version >/dev/null 2>&1 || fail COMPOSE 'A Docker Compose plugin nem érhető el.'
docker_cmd info >/dev/null 2>&1 || fail DOCKER 'A Docker daemon nem érhető el a futtató felhasználó számára.'

VALIDATOR=$(cat <<'PY'
import json
import pathlib
import re
import sys

def fail(code, message):
    print(f"FAIL: [{code}] {message}")
    raise SystemExit(1)

try:
    config = json.load(sys.stdin)
    if not isinstance(config, dict) or config.get("name") != "diku":
        fail("PROJECT", "A production Compose projekt neve diku legyen.")
    services = config.get("services", {})
    if not isinstance(services, dict) or not all(name in services for name in ("db", "backend", "frontend", "cloudflared")):
        fail("SERVICES", "A négy production szolgáltatás hiánytalan konfigurációja szükséges.")
    for service in services.values():
        if not isinstance(service, dict):
            fail("CONFIG", "Érvénytelen Compose szolgáltatáskonfiguráció.")
        if service.get("ports") or service.get("network_mode") == "host":
            fail("PORTS", "Production szolgáltatás nem publikálhat hostportot és nem használhat host hálózatot.")
        environment = service.get("environment") or {}
        if not isinstance(environment, dict):
            fail("CONFIG", "Nem normalizált Compose environment formátum.")
        if "TUNNEL_TOKEN" in environment:
            fail("TOKEN_ENV", "Tunnel token nem szerepelhet a szolgáltatások környezeti változói között.")

    backend = services["backend"].get("environment") or {}
    if backend.get("SPRING_PROFILES_ACTIVE") != "production":
        fail("PROFILE", "A backend kizárólag production profillal induljon.")
    if str(backend.get("SECURE_COOKIE", "")).lower() != "true":
        fail("COOKIE", "Production környezetben SECURE_COOKIE=true szükséges.")
    digest = re.compile(r"^[^\s@]+@sha256:[0-9a-fA-F]{64}$")
    for name in ("db", "cloudflared"):
        if not digest.fullmatch(str(services[name].get("image", ""))):
            fail("DIGEST", "A MariaDB és cloudflared image pontos, 64 hex karakteres SHA-256 digestet igényel.")

    tunnel = services["cloudflared"]
    if (tunnel.get("environment") or {}).get("TUNNEL_TOKEN_FILE") != "/run/secrets/cloudflared-token":
        fail("TOKEN_FILE", "A cloudflared TUNNEL_TOKEN_FILE értéke /run/secrets/cloudflared-token legyen.")
    for command in (tunnel.get("command", []), tunnel.get("entrypoint", [])):
        text = " ".join(command) if isinstance(command, list) else str(command or "")
        if re.search(r"(?:^|\s)--token(?:=|\s|$)", text):
            fail("TOKEN_ARGUMENT", "A token nem adható meg parancssori argumentumként.")
    mounts = tunnel.get("secrets") or []
    if not isinstance(mounts, list) or not any(
        item == "cloudflared-token" or isinstance(item, dict)
        and item.get("source") == "cloudflared-token"
        and item.get("target", "cloudflared-token") in ("cloudflared-token", "/run/secrets/cloudflared-token")
        for item in mounts
    ):
        fail("TOKEN_MOUNT", "A cloudflared-token secret nincs a megfelelő konténerútvonalra csatolva.")
    definition = (config.get("secrets") or {}).get("cloudflared-token")
    if not isinstance(definition, dict) or not definition.get("file") or definition.get("external"):
        fail("TOKEN_SOURCE", "A cloudflared-token helyi fájlból származó secret legyen.")
    root = pathlib.Path(sys.argv[1])
    actual = pathlib.Path(definition["file"])
    if not actual.is_absolute():
        actual = root / actual
    if actual.resolve() != (root / "secrets/cloudflared-token").resolve():
        fail("TOKEN_SOURCE", "A secret forrása kizárólag a secrets/cloudflared-token fájl lehet.")
except SystemExit:
    raise
except Exception:
    fail("CONFIG", "A Compose konfiguráció nem ellenőrizhető; nyers adatot nem írunk ki.")
PY
)

# Compose may include secrets even in errors. Both stderr streams are suppressed;
# Python emits only fixed messages. The resolved JSON stays in the pipe/memory.
if ! docker_cmd compose --project-name diku --project-directory "$ROOT" --env-file "$ROOT/.env.production" -f "$ROOT/compose.production.yml" config --format json 2>/dev/null \
    | python3 -I -B -c "$VALIDATOR" "$ROOT" 2>/dev/null; then
  fail CONFIG_CHECK 'A production konfiguráció ellenőrzése sikertelen. Nyers Compose-kimenet nincs naplózva.'
fi
printf '%s\n' 'OK: production fájljogok, diku projekt, belső hálózat, secure cookie, image digestek és tunnel file-secret.'
printf '%s\n' 'OK: csak olvasó ellenőrzés kész; ez nem igazolja a DNS/Tunnel elérhetőségét vagy a mentés visszaállíthatóságát.'
