#!/usr/bin/env bash
# Ubuntu VPS: a .release.env kizárólag ellenőrzött, commitolt alkalmazásimage-pár.
set -Eeuo pipefail
umask 077
RETRY_FAILED=0
if [[ $# -gt 0 ]]; then
  [[ $# -eq 1 && $1 == --retry-failed ]] || { echo 'Használat: deploy.sh [--retry-failed]' >&2; exit 2; }
  RETRY_FAILED=1
fi
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"
mkdir -p .deploy
exec 9>.deploy/deploy.lock
flock -n 9 || { echo 'Másik telepítés/mentés folyamatban; kihagyva.'; exit 0; }
test -f .env.production || { echo '.env.production hiányzik.' >&2; exit 1; }
if grep -q '^[^#]*=CHANGE_ME' .env.production; then
  echo 'Először állítsd be a production titkokat.' >&2; exit 1
fi

# A shell exportált image-változói nem írhatják felül a rögzített kiadást.
DOCKER=(env -u BACKEND_IMAGE -u FRONTEND_IMAGE -u COMPOSE_PROJECT_NAME docker)
compose() {
  local release=$1
  shift
  local args=(compose --project-name diku --env-file .env.production)
  [[ -z "$release" ]] || args+=(--env-file "$release")
  "${DOCKER[@]}" "${args[@]}" -f compose.production.yml "$@"
}
atomic_copy() {
  cp -- "$1" "$2.tmp.$$"
  mv -f -- "$2.tmp.$$" "$2"
}
valid_release() {
  [[ -f "$1" && $(wc -l < "$1") -eq 2 ]] &&
    grep -Eq '^BACKEND_IMAGE=ghcr\.io/diku-erettsegi/backend@sha256:[a-f0-9]{64}$' "$1" &&
    grep -Eq '^FRONTEND_IMAGE=ghcr\.io/diku-erettsegi/frontend@sha256:[a-f0-9]{64}$' "$1"
}
quarantine() {
  atomic_copy .deploy/pending.env .deploy/failed.env
  printf '%s %s\n' "$(date -u +%FT%TZ)" "$1" > .deploy/failed-reason
}
rollback() {
  # DB-migrációt soha nem fordítunk automatikusan vissza.
  if [[ -f .release.env ]]; then
    if compose .release.env up -d --wait --wait-timeout 240; then
      rm -f .deploy/pending.env .deploy/recovery-required
      echo 'Az előző alkalmazásimage-ek ismét egészségesek. DB-migrációt nem fordítottunk vissza.' >&2
      return 0
    fi
  else
    # Első telepítés: nincs ismerten jó kiadás; az adatokat megtartjuk.
    if compose .deploy/pending.env stop frontend backend cloudflared; then
      rm -f .deploy/pending.env .deploy/recovery-required
      echo 'Nincs korábbi kiadás. Az alkalmazások leálltak; a DB és a volume-ok megmaradtak.' >&2
      return 0
    fi
  fi
  date -u +%FT%TZ > .deploy/recovery-required
  echo 'A helyreállítás IS SIKERTELEN. Kézi állapotellenőrzés szükséges; új kísérlet csak --retry-failed kapcsolóval.' >&2
  return 1
}

BASE_RELEASE=''
if [[ -f .release.env ]]; then
  valid_release .release.env || { echo 'Érvénytelen .release.env; kézi ellenőrzés szükséges.' >&2; exit 1; }
  BASE_RELEASE=.release.env
fi
bash scripts/preflight.sh
compose "$BASE_RELEASE" config --quiet
if [[ -f .deploy/recovery-required && $RETRY_FAILED -ne 1 ]]; then
  echo 'Korábbi helyreállítás sikertelen. Ellenőrzés után: deploy.sh --retry-failed.' >&2
  exit 1
fi
if [[ -f .deploy/pending.env ]]; then
  valid_release .deploy/pending.env || { echo 'Érvénytelen pending állapot; kézi ellenőrzés szükséges.' >&2; exit 1; }
  if [[ -f .release.env ]] && cmp -s .release.env .deploy/pending.env; then
    # A commit már megtörtént, csak az állapotjelző törlése szakadt meg.
    rm -f .deploy/pending.env .deploy/recovery-required
  else
    quarantine interrupted
    if [[ ! -f .release.env && $RETRY_FAILED -ne 1 ]]; then
      echo 'Megszakadt első telepítés. Ellenőrizd a konténereket; folytatás: deploy.sh --retry-failed.' >&2
      exit 1
    fi
    rollback || exit 1
  fi
elif [[ -f .deploy/recovery-required ]]; then
  echo 'Hiányzó pending állapot mellett helyreállítási jelző található; kézi ellenőrzés szükséges.' >&2
  exit 1
fi

for component in backend frontend; do
  "${DOCKER[@]}" pull "ghcr.io/diku-erettsegi/$component:main"
done
NEXT_BACKEND=$("${DOCKER[@]}" image inspect ghcr.io/diku-erettsegi/backend:main --format '{{index .RepoDigests 0}}')
NEXT_FRONTEND=$("${DOCKER[@]}" image inspect ghcr.io/diku-erettsegi/frontend:main --format '{{index .RepoDigests 0}}')
printf 'BACKEND_IMAGE=%s\nFRONTEND_IMAGE=%s\n' "$NEXT_BACKEND" "$NEXT_FRONTEND" > .deploy/candidate.env
valid_release .deploy/candidate.env || { echo 'Nem várt registry/image digest.' >&2; exit 1; }
if [[ -f .release.env ]] && cmp -s .release.env .deploy/candidate.env; then
  echo 'Nincs új kiadás.'; exit 0
fi
if [[ -f .deploy/failed.env ]] && cmp -s .deploy/failed.env .deploy/candidate.env && [[ $RETRY_FAILED -ne 1 ]]; then
  echo 'Ez az image-pár már hibásnak bizonyult; kihagyva. Javítás/ellenőrzés után: deploy.sh --retry-failed.'
  exit 0
fi
compose .deploy/candidate.env config --quiet
DB_RUNNING=$(compose "$BASE_RELEASE" ps --status running --quiet db)
DB_EXISTS=$(compose "$BASE_RELEASE" ps --all --quiet db)
DB_VOLUMES=$("${DOCKER[@]}" volume ls --filter label=com.docker.compose.project=diku --filter label=com.docker.compose.volume=database --format '{{.Name}}')
if [[ -z "$DB_RUNNING" && ( -n "$DB_EXISTS" || -n "$DB_VOLUMES" ) ]]; then
  echo 'Tárolt, de nem futó adatbázis található. Frissítés tiltva: indítsd el és ellenőrizd a jelenlegi DB-t, majd készüljön mentés.' >&2
  exit 1
fi
if [[ -f .release.env ]]; then
  atomic_copy .release.env .deploy/previous.env
else
  rm -f .deploy/previous.env
fi

# A jelző a backend első leállítása ELŐTT tartós; megszakításkor recovery következik.
atomic_copy .deploy/candidate.env .deploy/pending.env
if [[ -n "$DB_RUNNING" ]]; then
  if ! DIKU_DEPLOY_LOCK_HELD=1 DIKU_BACKUP_KEEP_STOPPED=1 bash scripts/backup.sh; then
    quarantine backup-failed
    rollback || true
    exit 1
  fi
fi
if compose .deploy/pending.env up -d --wait --wait-timeout 240; then
  # Atomi commitpont: eddig minden olvasó a korábbi egészséges párt látta.
  atomic_copy .deploy/pending.env .release.env
  atomic_copy .release.env .deploy/last-success.env
  date -u +%FT%TZ > .deploy/last-success-at
  if [[ -f .deploy/failed.env ]] && cmp -s .release.env .deploy/failed.env; then
    rm -f .deploy/failed.env .deploy/failed-reason
  fi
  rm -f .deploy/pending.env .deploy/recovery-required
  echo 'Telepítés kész, konténerek egészségesek.'
else
  echo 'Sikertelen frissítés.' >&2
  quarantine health-failed
  rollback || true
  exit 1
fi
