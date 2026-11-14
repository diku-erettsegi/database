#!/usr/bin/env bash
# Isolated destructive-operation regression tests: only mktemp fixtures are used.
set -Eeuo pipefail
SOURCE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
TEST_ROOT=$(mktemp -d)
trap 'rm -rf -- "$TEST_ROOT"' EXIT
mkdir -p "$TEST_ROOT/bin" "$TEST_ROOT/checkout/scripts" "$TEST_ROOT/checkout/backups" "$TEST_ROOT/outside"
cp "$SOURCE/scripts/backup-retention.sh" "$TEST_ROOT/checkout/scripts/"
export TEST_NOW
TEST_NOW=$(/usr/bin/date -u --date='2026-11-13 12:00:00' +%s)
# Freeze only the current clock; all calendar parsing remains GNU date's real code.
cat > "$TEST_ROOT/bin/date" <<'MOCK'
#!/usr/bin/env bash
if [[ "$*" == '-u +%s' ]]; then printf '%s\n' "$TEST_NOW"; else exec /usr/bin/date "$@"; fi
MOCK
# Real kernel flock, fail immediately instead of waiting a minute in lock test.
cat > "$TEST_ROOT/bin/flock" <<'MOCK'
#!/usr/bin/env bash
if [[ "$1" == -w && "$2" == 60 ]]; then shift 2; exec /usr/bin/flock -n "$@"; fi
exec /usr/bin/flock "$@"
MOCK
# Exercise the mount-root refusal without requiring a privileged test container.
cat > "$TEST_ROOT/bin/mountpoint" <<'MOCK'
#!/usr/bin/env bash
[[ ${!#} != */20261001T120000-14 ]] || exit 0
exec /usr/bin/mountpoint "$@"
MOCK
chmod +x "$TEST_ROOT/bin/date" "$TEST_ROOT/bin/flock" "$TEST_ROOT/bin/mountpoint"
export PATH="$TEST_ROOT/bin:$PATH"
cd "$TEST_ROOT/checkout"
CASES=0
pass() { CASES=$((CASES + 1)); printf 'PASS: %s\n' "$1"; }
prune() { bash scripts/backup-retention.sh "$@" > "$TEST_ROOT/result.log" 2>&1; }
fails() { if "$@"; then echo 'Expected failure.' >&2; cat "$TEST_ROOT/result.log" >&2; exit 1; fi; }
fixture() { mkdir -p "backups/$1"; printf '%s\n' 'test-only' > "backups/$1/database.sql"; }

fixture 20261014T120000-1
fixture 20261014T120001-2
fixture 20261112T120000-3
fixture 20261114T120000-4
prune --dry-run
test -f backups/20261014T120000-1/database.sql
grep -q 'Would remove expired backup: 20261014T120000-1' "$TEST_ROOT/result.log"
! grep -q 'Would remove.*20261014T120001-2' "$TEST_ROOT/result.log"
pass 'dry run preserves data and uses the exact UTC 30-day boundary'

touch -d '2020-01-01' backups/20261112T120000-3
touch backups/20261014T120000-1
prune
test ! -e backups/20261014T120000-1
test -f backups/20261014T120001-2/database.sql
test -f backups/20261112T120000-3/database.sql
test -f backups/20261114T120000-4/database.sql
pass 'creation timestamp controls expiry; filesystem mtime and future dates do not'

# COMPLETE is deliberately absent: failed backups must not retain PII forever.
fixture 20261001T120000-5
prune
test ! -e backups/20261001T120000-5
pass 'old incomplete backups also expire'

fixture important-manual-copy
fixture 20260230T120000-6
fixture 20261301T120000-7
fixture 20261001T120000-0
printf '%s\n' keep > backups/20261001T120000-8
prune
test -f backups/important-manual-copy/database.sql
test -f backups/20260230T120000-6/database.sql
test -f backups/20261301T120000-7/database.sql
test -f backups/20261001T120000-0/database.sql
test -f backups/20261001T120000-8
pass 'unknown names, invalid dates, invalid PID and ordinary files survive'

printf '%s\n' 'outside must survive' > "$TEST_ROOT/outside/keep"
ln -s "$TEST_ROOT/outside" backups/20261001T120000-9
fixture 20261001T120000-10
ln -s "$TEST_ROOT/outside/keep" backups/20261001T120000-10/uploads.tar.gz
fixture 20261001T120000-11
mkdir backups/20261001T120000-11/nested
fixture 20261001T120000-12
printf '%s\n' keep > backups/20261001T120000-12/.unrecognized
prune
test -L backups/20261001T120000-9
test -L backups/20261001T120000-10/uploads.tar.gz
test -d backups/20261001T120000-11/nested
test -f backups/20261001T120000-12/.unrecognized
test "$(cat "$TEST_ROOT/outside/keep")" = 'outside must survive'
pass 'symlinks, nested directories and hidden unknown contents never become deletion targets'

fixture 20261001T120000-14
prune
test -f backups/20261001T120000-14/database.sql
pass 'a mounted candidate is never traversed or removed'

fixture 20261001T120000-13
exec 8>.deploy/deploy.lock
flock -n 8
fails prune
test -f backups/20261001T120000-13/database.sql
flock -u 8
exec 8>&-
prune
test ! -e backups/20261001T120000-13
pass 'shared deployment lock prevents concurrent backup deletion'

mv backups backup-fixtures
ln -s "$TEST_ROOT/outside" backups
fails prune
test -f "$TEST_ROOT/outside/keep"
rm -- backups
mv backup-fixtures backups
pass 'symlink backup root is rejected before walking any files'

mv .deploy/deploy.lock .deploy/deploy.lock.saved
ln -s "$TEST_ROOT/outside/keep" .deploy/deploy.lock
fails prune
test "$(cat "$TEST_ROOT/outside/keep")" = 'outside must survive'
rm -- .deploy/deploy.lock
mv .deploy/deploy.lock.saved .deploy/deploy.lock
fails prune --unknown
pass 'symlink lock and unexpected arguments fail closed'

printf 'PASS: %s backup retention regression cases.\n' "$CASES"
