#!/usr/bin/env bash
# Explicit installation on the dedicated Ubuntu VPS. Does not run backup prune,
# recreate containers, change application data or modify SSH/firewall settings.
# Host-wide journal settings apply to all services, not only DIKU containers.
# Restarting journald applies its retention policy to existing host journals too.
set -Eeuo pipefail
umask 027
[[ $(id -u) == 0 ]] || { echo 'Run as root on the dedicated DIKU VPS.' >&2; exit 1; }
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
[[ "$ROOT" == /opt/diku/database ]] || { echo 'Expected /opt/diku/database checkout.' >&2; exit 1; }
. /etc/os-release
[[ $ID == ubuntu && $VERSION_ID == 24.04 ]] || { echo 'Ubuntu 24.04 required.' >&2; exit 1; }
id diku-deploy >/dev/null
for directory in "$ROOT/.deploy" "$ROOT/backups"; do
  [[ ! -L "$directory" ]] || { echo 'Refusing symlink state directory.' >&2; exit 1; }
  if [[ ! -e "$directory" ]]; then
    install -d -m 0700 -o diku-deploy -g diku-deploy "$directory"
  fi
  [[ -d "$directory" && $(stat -c %U "$directory") == diku-deploy ]] || {
    echo 'State directories must already be owned by diku-deploy.' >&2; exit 1;
  }
done
install -d -m 0755 /etc/systemd/journald.conf.d
install -m 0644 "$ROOT/systemd/journald-diku-retention.conf" /etc/systemd/journald.conf.d/90-diku-retention.conf
for unit in diku-backup-retention.service diku-backup-retention.timer diku-journal-retention.service diku-journal-retention.timer; do
  install -m 0644 "$ROOT/systemd/$unit" "/etc/systemd/system/$unit"
done
systemctl daemon-reload
systemctl restart systemd-journald
journalctl --flush
# Do not use --now: Persistent timers could immediately prune old data. The
# deployment runbook deliberately activates them after preview and verification.
systemctl enable diku-backup-retention.timer diku-journal-retention.timer
echo 'Retention installed and enabled for boot; this script does not start timers.'
echo 'Already-active timers remain active. Existing journals now use the new policy.'
echo 'Preview as diku-deploy: bash /opt/diku/database/scripts/backup-retention.sh --dry-run'
echo 'Then activate: systemctl start diku-backup-retention.timer diku-journal-retention.timer'
echo 'Recreate production containers to switch their existing log driver to journald.'
echo 'Review legacy JSON/file logs and any imjournal/syslog readers separately.'
