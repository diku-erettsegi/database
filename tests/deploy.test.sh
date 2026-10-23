#!/usr/bin/env bash
# Fake Docker regression tests. No registry, containers, real secrets or live data are touched.
set -Eeuo pipefail
SOURCE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
TEST_ROOT=$(mktemp -d)
cleanup() {
  local result=$?
  if [[ $result -ne 0 ]]; then
    echo "FAIL: scenario ${CASE:-setup}" >&2
    [[ ! -f result.log ]] || cat result.log >&2
    [[ -z ${MOCK_LOG:-} || ! -f "$MOCK_LOG" ]] || cat "$MOCK_LOG" >&2
  fi
  rm -rf -- "$TEST_ROOT"
  exit "$result"
}
trap cleanup EXIT
mkdir -p "$TEST_ROOT/bin"
DIGEST_OLD=$(printf '1%.0s' {1..64})
DIGEST_NEW=$(printf '3%.0s' {1..64})
DIGEST_FRONTEND=$(printf '2%.0s' {1..64})
export OLD_BACKEND="ghcr.io/diku-erettsegi/backend@sha256:$DIGEST_OLD"
export NEW_BACKEND="ghcr.io/diku-erettsegi/backend@sha256:$DIGEST_NEW"
export MOCK_FRONTEND="ghcr.io/diku-erettsegi/frontend@sha256:$DIGEST_FRONTEND"
cat > "$TEST_ROOT/bin/docker" <<'MOCK'
#!/usr/bin/env bash
set -Eeuo pipefail
[[ -z ${BACKEND_IMAGE+x} && -z ${FRONTEND_IMAGE+x} && -z ${COMPOSE_PROJECT_NAME+x} ]]
printf '%s\n' "$*" >> "$MOCK_RAW_LOG"
if [[ $1 == pull ]]; then exit 0; fi
if [[ $1 == image && $2 == inspect ]]; then
  if [[ $3 == *backend* ]]; then echo "$MOCK_BACKEND"; else echo "$MOCK_FRONTEND"; fi
  exit 0
fi
if [[ $1 == volume && $2 == ls ]]; then
  [[ "$*" == *'label=com.docker.compose.project=diku'* ]]
  [[ "$*" == *'label=com.docker.compose.volume=database'* ]]
  if [[ ${MOCK_DB_VOLUME:-0} == 1 ]]; then echo diku_database; fi
  exit 0
fi
[[ $1 == compose ]]
shift
RELEASE=''
PROJECT=''
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-name) PROJECT=$2; shift 2 ;;
    --env-file) RELEASE=$2; shift 2 ;;
    -f) shift 2 ;;
    *) break ;;
  esac
done
[[ $PROJECT == diku ]]
OP=$1
shift
TARGET=$(sed -n 's/^BACKEND_IMAGE=//p' "$RELEASE")
COMMITTED=NONE
[[ ! -f .release.env ]] || COMMITTED=$(sed -n 's/^BACKEND_IMAGE=//p' .release.env)
printf '%s|%s|%s|%s\n' "$OP" "$RELEASE" "$TARGET" "$COMMITTED" >> "$MOCK_LOG"
case "$OP" in
  config) exit "${MOCK_CONFIG_FAIL:-0}" ;;
  ps)
    SERVICE=${!#}
    if [[ $SERVICE == db ]]; then
      if [[ "$*" == *'--all'* && ${MOCK_DB_EXISTS:-0} == 1 ]]; then echo db-container
      elif [[ "$*" == *'--status running'* && ${MOCK_DB_RUNNING:-0} == 1 ]]; then echo db-container
      fi
    elif [[ $SERVICE == backend && ${MOCK_BACKEND_RUNNING:-0} == 1 ]]; then echo backend-container
    fi ;;
  up)
    [[ -z ${MOCK_FAIL_IMAGE:-} || "$TARGET" != "$MOCK_FAIL_IMAGE" ]] || exit 1
    [[ -z ${MOCK_ROLLBACK_FAIL:-} || "$TARGET" != "$MOCK_ROLLBACK_FAIL" ]] || exit 1 ;;
  stop) exit "${MOCK_STOP_FAIL:-0}" ;;
  start) exit "${MOCK_START_FAIL:-0}" ;;
  exec)
    [[ ${MOCK_DUMP_FAIL:-0} != 1 ]] || exit 1
    printf '%s\n' '-- Fake consistent SQL dump' ;;
  run)
    if [[ ${MOCK_TAR_FAIL:-0} == 1 ]]; then printf 'invalid archive'; else tar -czf - .env.production; fi ;;
  *) echo "Unexpected Docker command: $OP $*" >&2; exit 99 ;;
esac
MOCK
chmod +x "$TEST_ROOT/bin/docker"
export PATH="$TEST_ROOT/bin:$PATH"
CASES=0
new_case() {
  CASE="$TEST_ROOT/$1"
  mkdir -p "$CASE/scripts" "$CASE/.deploy"
  cp "$SOURCE/scripts/deploy.sh" "$SOURCE/scripts/backup.sh" "$CASE/scripts/"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$CASE/scripts/preflight.sh"
  printf 'DB_NAME=diku_test\n' > "$CASE/.env.production"
  cd "$CASE"
  export MOCK_LOG="$CASE/operations.log" MOCK_RAW_LOG="$CASE/docker.log"
  : > "$MOCK_LOG"
  : > "$MOCK_RAW_LOG"
  export MOCK_BACKEND="$OLD_BACKEND"
  export MOCK_DB_RUNNING=0 MOCK_DB_EXISTS=0 MOCK_DB_VOLUME=0 MOCK_BACKEND_RUNNING=0
  unset MOCK_FAIL_IMAGE MOCK_ROLLBACK_FAIL MOCK_CONFIG_FAIL MOCK_STOP_FAIL MOCK_START_FAIL MOCK_DUMP_FAIL MOCK_TAR_FAIL
  # These ambient overrides must never change production images/project.
  export BACKEND_IMAGE=wrong-backend FRONTEND_IMAGE=wrong-frontend COMPOSE_PROJECT_NAME=wrong-project
}
release() { printf 'BACKEND_IMAGE=%s\nFRONTEND_IMAGE=%s\n' "$1" "$MOCK_FRONTEND" > "$2"; }
existing_release() {
  release "$OLD_BACKEND" .release.env
  export MOCK_BACKEND="$NEW_BACKEND"
  export MOCK_DB_RUNNING=1 MOCK_DB_EXISTS=1 MOCK_DB_VOLUME=1 MOCK_BACKEND_RUNNING=1
}
deploy() { bash scripts/deploy.sh "$@" > result.log 2>&1; }
backup() { bash scripts/backup.sh > result.log 2>&1; }
fails() {
  if "$@"; then echo "FAIL: expected failure: $*" >&2; cat result.log >&2; exit 1; fi
}
count() { grep -c "^$1|" "$MOCK_LOG" || true; }
assert_release() { grep -Fxq "BACKEND_IMAGE=$1" .release.env; }
pass() { CASES=$((CASES + 1)); echo "PASS: $1"; }

new_case first
deploy
assert_release "$OLD_BACKEND"
test -f .deploy/last-success-at
cmp .release.env .deploy/last-success.env
test ! -f .deploy/pending.env
test "$(count up)" -eq 1
grep -Fq "up|.deploy/pending.env|$OLD_BACKEND|NONE" "$MOCK_LOG"
test "$(count exec)" -eq 0
pass 'first deployment commits only after health'

deploy
test "$(count up)" -eq 1
pass 'unchanged pair does not restart or back up'

new_case success
existing_release
deploy
assert_release "$NEW_BACKEND"
test "$(count exec)" -eq 1
test "$(count start)" -eq 0
grep -Fq "up|.deploy/pending.env|$NEW_BACKEND|$OLD_BACKEND" "$MOCK_LOG"
BACKUP=$(find backups -name COMPLETE -print -quit)
test -n "$BACKUP"
(cd "$(dirname "$BACKUP")" && sha256sum -c SHA256SUMS >/dev/null)
grep -Fxq "BACKEND_IMAGE=$OLD_BACKEND" "$(dirname "$BACKUP")/release.env"
test "$(count stop)" -eq 1
pass 'upgrade backs up the committed release and stays stopped until candidate up'

new_case unhealthy
existing_release
export MOCK_FAIL_IMAGE="$NEW_BACKEND"
fails deploy
assert_release "$OLD_BACKEND"
test "$(count up)" -eq 2
test ! -f .deploy/pending.env
test ! -f .deploy/recovery-required
grep -Fq "up|.release.env|$OLD_BACKEND|$OLD_BACKEND" "$MOCK_LOG"
grep -Fxq "BACKEND_IMAGE=$NEW_BACKEND" .deploy/failed.env
pass 'unhealthy upgrade rolls back without committing candidate'

deploy
test "$(count up)" -eq 2
test "$(count exec)" -eq 1
pass 'quarantined pair does not repeatedly restart or back up'

unset MOCK_FAIL_IMAGE
deploy --retry-failed
assert_release "$NEW_BACKEND"
test ! -f .deploy/failed.env
test "$(count up)" -eq 3
pass 'explicit retry succeeds and clears matching quarantine'

new_case rollback_failure
existing_release
export MOCK_FAIL_IMAGE="$NEW_BACKEND" MOCK_ROLLBACK_FAIL="$OLD_BACKEND"
fails deploy
assert_release "$OLD_BACKEND"
test -f .deploy/recovery-required
test -f .deploy/pending.env
grep -q 'IS SIKERTELEN' result.log
fails deploy
test "$(count up)" -eq 2
pass 'rollback failure is reported and blocks automatic repetition'
unset MOCK_FAIL_IMAGE MOCK_ROLLBACK_FAIL
deploy --retry-failed
assert_release "$NEW_BACKEND"
test ! -f .deploy/recovery-required
test ! -f .deploy/pending.env
test "$(count up)" -eq 4
pass 'explicit recovery restores committed pair before retry'

new_case interrupted
existing_release
release "$NEW_BACKEND" .deploy/pending.env
deploy
assert_release "$OLD_BACKEND"
test "$(count up)" -eq 1
test "$(count exec)" -eq 0
test ! -f .deploy/pending.env
grep -q interrupted .deploy/failed-reason
pass 'interrupted attempt recovers and quarantines candidate'

new_case interrupted_first
release "$NEW_BACKEND" .deploy/pending.env
fails deploy
test ! -f .release.env
test "$(count up)" -eq 0
test -f .deploy/pending.env
pass 'interrupted first deployment fails closed without a committed release'

new_case committed_marker
release "$OLD_BACKEND" .release.env
release "$OLD_BACKEND" .deploy/pending.env
deploy
test ! -f .deploy/pending.env
test "$(count up)" -eq 0
pass 'interruption after atomic commit only cleans the marker'

new_case offline_container
existing_release
export MOCK_DB_RUNNING=0
fails deploy
assert_release "$OLD_BACKEND"
test "$(count up)" -eq 0
test "$(count stop)" -eq 0
test ! -f .deploy/pending.env
pass 'stopped existing DB prevents update without backup'

new_case orphan_volume
export MOCK_DB_VOLUME=1
fails deploy
test ! -f .release.env
test "$(count up)" -eq 0
test "$(count exec)" -eq 0
pass 'persistent DB volume without container also prevents unbacked update'

new_case backup_failure
existing_release
export MOCK_DUMP_FAIL=1
fails deploy
assert_release "$OLD_BACKEND"
test "$(count up)" -eq 1
test "$(count start)" -eq 1
test -z "$(find backups -name COMPLETE -print -quit)"
! grep -q '^up|.deploy/pending.env|' "$MOCK_LOG"
grep -q backup-failed .deploy/failed-reason
pass 'failed SQL backup restarts old backend and never applies candidate'

new_case invalid_archive
existing_release
export MOCK_TAR_FAIL=1
fails deploy
test -z "$(find backups -name COMPLETE -print -quit)"
! grep -q '^up|.deploy/pending.env|' "$MOCK_LOG"
assert_release "$OLD_BACKEND"
pass 'invalid uploads archive prevents candidate update'

new_case first_failure
export MOCK_FAIL_IMAGE="$OLD_BACKEND"
fails deploy
test ! -f .release.env
test -f .deploy/failed.env
test ! -f .deploy/pending.env
grep -q 'stop frontend backend cloudflared' "$MOCK_RAW_LOG"
! grep -qE 'down|volume rm' "$MOCK_RAW_LOG"
pass 'failed first deployment stops application only and preserves data'

new_case standalone_backup
existing_release
backup
test "$(count start)" -eq 1
test "$(count up)" -eq 0
test -n "$(find backups -name COMPLETE -print -quit)"
pass 'standalone backup restarts previously running backend with health wait'
export MOCK_START_FAIL=1
fails backup
grep -q 'újraindítás sikertelen' result.log
pass 'standalone backup reports failed backend restart'

new_case invalid_config
export MOCK_CONFIG_FAIL=1
fails deploy
test "$(count up)" -eq 0
test ! -f .deploy/pending.env
pass 'invalid Compose configuration fails before any mutation'

new_case preflight_failure
printf '#!/usr/bin/env bash\nexit 1\n' > scripts/preflight.sh
fails deploy
test ! -s "$MOCK_RAW_LOG"
test ! -f .deploy/pending.env
pass 'failed production preflight blocks image pulls and mutations'

new_case standalone_pending
existing_release
release "$NEW_BACKEND" .deploy/pending.env
fails backup
test ! -s "$MOCK_RAW_LOG"
test -f .deploy/pending.env
pass 'standalone backup does not mislabel an unfinished release'

new_case lock
exec 8>.deploy/deploy.lock
flock -n 8
deploy
test ! -s "$MOCK_RAW_LOG"
fails backup
flock -u 8
exec 8>&-
pass 'deployment and standalone backup share the same exclusive lock'

printf 'PASS: %s deployment/backup regression cases.\n' "$CASES"
