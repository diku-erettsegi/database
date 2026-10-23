#!/usr/bin/env bash
# One-time host preparation, explicitly run as root on the DIKU Ubuntu VPS.
# Does not modify SSH/firewall rules, create application secrets, or enable deploy timers.
set -Eeuo pipefail
umask 027
[[ $(id -u) == 0 ]] || { echo 'Run as root.' >&2; exit 1; }
[[ -r /etc/os-release ]] || exit 1
. /etc/os-release
[[ $ID == ubuntu && $VERSION_ID == 24.04 ]] || { echo 'This script targets Ubuntu 24.04 LTS.' >&2; exit 1; }
[[ $(dpkg --print-architecture) == amd64 ]] || { echo 'This VPS configuration targets amd64.' >&2; exit 1; }
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq ca-certificates curl git python3 util-linux
install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod 0644 /etc/apt/keyrings/docker.asc
SOURCE=$(mktemp)
trap 'rm -f -- "$SOURCE"' EXIT
cat > "$SOURCE" <<'REPO'
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: noble
Components: stable
Architectures: amd64
Signed-By: /etc/apt/keyrings/docker.asc
REPO
if [[ -e /etc/apt/sources.list.d/docker.sources ]] && ! cmp -s "$SOURCE" /etc/apt/sources.list.d/docker.sources; then
  echo 'Existing Docker apt source differs. Review it before proceeding.' >&2
  exit 1
fi
install -m 0644 "$SOURCE" /etc/apt/sources.list.d/docker.sources
apt-get update -qq
apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker
if ! id diku-deploy >/dev/null 2>&1; then
  adduser --disabled-password --gecos '' diku-deploy
fi
usermod -aG docker diku-deploy
if [[ ! -e /opt/diku ]]; then
  install -d -m 0750 -o diku-deploy -g diku-deploy /opt/diku
fi
[[ -d /opt/diku && ! -L /opt/diku && $(stat -c %U /opt/diku) == diku-deploy ]] || {
  echo '/opt/diku must be a directory owned by diku-deploy; no existing ownership was changed.' >&2
  exit 1
}
runuser -u diku-deploy -- docker version --format '{{.Server.Version}}'
runuser -u diku-deploy -- docker compose version
echo 'Host ready. SSH/firewall and application activation remain separate steps.'
