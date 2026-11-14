#!/usr/bin/env bash
# Delete only DIKU's own expired backup directories. No Docker or live DB access.
# Age is the UTC creation timestamp in backup.sh's directory name, never mtime.
set -Eeuo pipefail
umask 077
DRY_RUN=0
if [[ $# -gt 0 ]]; then
  [[ $# -eq 1 && $1 == --dry-run ]] || { echo 'Usage: backup-retention.sh [--dry-run]' >&2; exit 2; }
  DRY_RUN=1
fi
for required in realpath flock date mountpoint rm; do
  command -v "$required" >/dev/null || { echo "Required retention utility missing: $required" >&2; exit 1; }
done
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
BACKUP_ROOT="$ROOT/backups"
[[ ! -L "$BACKUP_ROOT" ]] || { echo 'Refusing symlink backup root.' >&2; exit 1; }
[[ -e "$BACKUP_ROOT" ]] || { echo 'No backup directory; nothing to prune.'; exit 0; }
[[ -d "$BACKUP_ROOT" && $(realpath -e -- "$BACKUP_ROOT") == "$ROOT/backups" ]] || exit 1
[[ ! -L "$ROOT/.deploy" && ! -L "$ROOT/.deploy/deploy.lock" ]] || {
  echo 'Refusing symlink deployment lock path.' >&2; exit 1;
}
mkdir -p "$ROOT/.deploy"
exec 9>"$ROOT/.deploy/deploy.lock"
# Do not remove a backup while backup.sh/deploy.sh is writing it.
flock -w 60 9 || { echo 'Backup/deployment still running; retention must retry.' >&2; exit 1; }
CUTOFF=$(( $(date -u +%s) - 30 * 86400 ))
REMOVED=0
SKIPPED=0
shopt -s nullglob dotglob
for candidate in "$BACKUP_ROOT"/*; do
  name=${candidate##*/}
  # Unknown names, files and links are never deletion targets.
  if [[ ! $name =~ ^([0-9]{8}T[0-9]{6})-([1-9][0-9]*)$ || -L "$candidate" || ! -d "$candidate" ]]; then
    SKIPPED=$((SKIPPED + 1)); continue
  fi
  stamp=${BASH_REMATCH[1]}
  if ! created=$(date -u --date="${stamp:0:4}-${stamp:4:2}-${stamp:6:2} ${stamp:9:2}:${stamp:11:2}:${stamp:13:2}" +%s 2>/dev/null); then
    SKIPPED=$((SKIPPED + 1)); continue
  fi
  # Reject normalized/invalid dates instead of guessing an intended timestamp.
  if [[ $(date -u --date="@$created" +%Y%m%dT%H%M%S) != "$stamp" ]]; then
    SKIPPED=$((SKIPPED + 1)); continue
  fi
  (( created <= CUTOFF )) || continue
  [[ $(realpath -e -- "$candidate") == "$BACKUP_ROOT/$name" ]] || {
    echo "Refusing unexpected resolved backup path: $name" >&2; exit 1;
  }
  # --one-file-system cannot protect a mount used as rm's starting directory.
  if mountpoint -q -- "$candidate"; then
    echo "Skipped mounted backup directory: $name" >&2
    SKIPPED=$((SKIPPED + 1)); continue
  fi
  safe=1
  for member in "$candidate"/*; do
    # Partial failed backups expire too, but never descend into directories/links.
    case "${member##*/}" in
      database.sql|uploads.tar.gz|release.env|SHA256SUMS|COMPLETE) ;;
      *) safe=0 ;;
    esac
    [[ -f "$member" && ! -L "$member" ]] || safe=0
  done
  if (( ! safe )); then
    echo "Skipped unexpected backup contents: $name" >&2
    SKIPPED=$((SKIPPED + 1)); continue
  fi
  if (( DRY_RUN )); then
    printf 'Would remove expired backup: %s\n' "$name"
  else
    # Fixed absolute path, verified to be a direct child; rm never follows links.
    rm -rf --one-file-system --preserve-root -- "$candidate"
    printf 'Removed expired backup: %s\n' "$name"
  fi
  REMOVED=$((REMOVED + 1))
done
printf 'Backup retention: expired=%s skipped-unrecognized=%s dry-run=%s\n' "$REMOVED" "$SKIPPED" "$DRY_RUN"
