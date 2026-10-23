#!/usr/bin/env bash
# Konzisztens adatbázis + feltöltés mentés; rövid backend leállással.
set -Eeuo pipefail
umask 077
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"
mkdir -p .deploy backups
if [[ ${DIKU_DEPLOY_LOCK_HELD:-0} != 1 ]]; then
  exec 9>.deploy/deploy.lock
fi
# A deploy szülőből örökölt FD-n is ellenőrizzük a lockot.
flock -n 9 || { echo 'Másik mentés/telepítés folyamatban vagy hiányzó örökölt lock.' >&2; exit 1; }
if [[ ${DIKU_DEPLOY_LOCK_HELD:-0} != 1 && ( -f .deploy/pending.env || -f .deploy/recovery-required ) ]]; then
  echo 'Befejezetlen telepítés található. Önálló mentés előtt a deploy helyreállítása szükséges.' >&2
  exit 1
fi
COMPOSE=(env -u BACKEND_IMAGE -u FRONTEND_IMAGE -u COMPOSE_PROJECT_NAME docker compose --project-name diku --env-file .env.production)
[[ ! -f .release.env ]] || COMPOSE+=(--env-file .release.env)
COMPOSE+=(-f compose.production.yml)
"${COMPOSE[@]}" config --quiet
DB_RUNNING=$("${COMPOSE[@]}" ps --status running --quiet db)
[[ -n "$DB_RUNNING" ]] || { echo 'Mentéshez futó adatbázis szükséges; semmit nem frissítettünk.' >&2; exit 1; }
DEST="backups/$(date -u +%Y%m%dT%H%M%S)-$$"
mkdir -p "$DEST"
BACKEND_RUNNING=$("${COMPOSE[@]}" ps --status running --quiet backend)
finish() {
  local result=$?
  trap - EXIT
  # Sikeres deploy-mentés után a backend leállítva marad az új image indulásáig.
  # Hibánál és önálló mentésnél viszont helyreállítjuk az eredeti futó állapotot.
  if [[ -n "$BACKEND_RUNNING" && ( $result -ne 0 || ${DIKU_BACKUP_KEEP_STOPPED:-0} != 1 ) ]]; then
    if ! "${COMPOSE[@]}" start --wait --wait-timeout 180 backend; then
      echo 'A mentés utáni backend újraindítás sikertelen; kézi ellenőrzés szükséges.' >&2
      result=1
    fi
  fi
  exit "$result"
}
trap finish EXIT
"${COMPOSE[@]}" stop backend
"${COMPOSE[@]}" exec -T db sh -c 'MYSQL_PWD="$MARIADB_PASSWORD" mariadb-dump --user="$MARIADB_USER" --single-transaction --quick --skip-lock-tables "$MARIADB_DATABASE"' > "$DEST/database.sql"
"${COMPOSE[@]}" run --rm --no-deps --entrypoint tar backend -czf - -C /app/uploads . > "$DEST/uploads.tar.gz"
[[ ! -f .release.env ]] || cp .release.env "$DEST/release.env"
test -s "$DEST/database.sql"
tar -tzf "$DEST/uploads.tar.gz" >/dev/null
(
  cd "$DEST"
  FILES=(database.sql uploads.tar.gz)
  [[ ! -f release.env ]] || FILES+=(release.env)
  sha256sum "${FILES[@]}" > SHA256SUMS
)
printf '%s\n' 'complete' > "$DEST/COMPLETE"
echo "Mentés elkészült: $ROOT/$DEST"
# Megőrzés/offsite másolás külön, dokumentált üzemeltetési döntés.
