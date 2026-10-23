#!/usr/bin/env bash
# Isolated regression tests. No Docker daemon, real env file, token, or VPS access.
set +x
set -Eeuo pipefail
SOURCE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
TEST_ROOT=$(mktemp -d)
trap 'rm -rf -- "$TEST_ROOT"' EXIT
mkdir -p "$TEST_ROOT/scripts" "$TEST_ROOT/bin"
cp "$SOURCE/scripts/preflight.sh" "$TEST_ROOT/scripts/preflight.sh"
export MOCK_CONFIG="$TEST_ROOT/config.json"
export MOCK_LOG="$TEST_ROOT/docker.log"
export CANARY='preflight-secret-MUST-NOT-APPEAR-92bf'
export MOCK_FAILURE=''
export TEST_ROOT
cat > "$TEST_ROOT/bin/docker" <<'MOCK'
#!/usr/bin/env bash
set -eu
[[ -z ${BACKEND_IMAGE+x} && -z ${FRONTEND_IMAGE+x} && -z ${COMPOSE_PROJECT_NAME+x} ]] || { printf '%s\n' "$CANARY" >&2; exit 95; }
printf '%s\n' "$*" >> "$MOCK_LOG"
if [[ "$1" == info ]]; then
  if [[ "$MOCK_FAILURE" == daemon ]]; then printf '%s\n' "$CANARY" >&2; exit 1; fi
  exit 0
fi
if [[ "$*" == 'compose version' ]]; then
  if [[ "$MOCK_FAILURE" == plugin ]]; then printf '%s\n' "$CANARY" >&2; exit 1; fi
  exit 0
fi
if [[ "$*" == *'config --format json' ]]; then
  [[ "$*" == *'--project-name diku '* ]] || exit 96
  [[ "$*" == *"--env-file $TEST_ROOT/.env.production "* ]] || exit 97
  [[ "$*" == *"-f $TEST_ROOT/compose.production.yml "* ]] || exit 98
  if [[ "$MOCK_FAILURE" == config ]]; then printf '%s\n' "$CANARY"; printf '%s\n' "$CANARY" >&2; exit 1; fi
  cat "$MOCK_CONFIG"
  if [[ "$MOCK_FAILURE" == partial ]]; then printf '%s\n' "$CANARY" >&2; exit 1; fi
  exit 0
fi
printf '%s\n' "$CANARY" >&2
exit 99
MOCK
chmod +x "$TEST_ROOT/bin/docker"
export PATH="$TEST_ROOT/bin:$PATH"
export COMPOSE_PROJECT_NAME='not-the-production-project'
export BACKEND_IMAGE='untrusted-backend:latest'
export FRONTEND_IMAGE='untrusted-frontend:latest'

reset_case() {
  unset MOCK_FAILURE
  export MOCK_FAILURE=''
  rm -rf -- "$TEST_ROOT/secrets"
  mkdir -m 700 "$TEST_ROOT/secrets"
  printf 'DB_PASSWORD=%s\n# CHANGE_ME in a comment is harmless.\n' "$CANARY" > "$TEST_ROOT/.env.production"
  # A shell execution marker proves the env was read as text, never sourced.
  printf 'DO_NOT_EXECUTE=$(touch %q)\n' "$TEST_ROOT/sourced-env" >> "$TEST_ROOT/.env.production"
  chmod 600 "$TEST_ROOT/.env.production"
  printf '%s\n' "$CANARY" > "$TEST_ROOT/secrets/cloudflared-token"
  chmod 644 "$TEST_ROOT/secrets/cloudflared-token"
  : > "$MOCK_LOG"
  printf 'services: {}\n' > "$TEST_ROOT/compose.production.yml"
  python3 - "$MOCK_CONFIG" <<'PY'
import json, os, pathlib, sys
root = pathlib.Path(os.environ["TEST_ROOT"])
config = {
    "name": "diku",
    "services": {
        "db": {"image": "mariadb:11.4@sha256:" + "a" * 64, "environment": {"MARIADB_PASSWORD": os.environ["CANARY"]}},
        "backend": {"environment": {"SPRING_PROFILES_ACTIVE": "production", "SECURE_COOKIE": "true"}},
        "frontend": {"image": "ghcr.io/diku-erettsegi/frontend:main"},
        "cloudflared": {"image": "cloudflare/cloudflared:2026.10.3@sha256:" + "b" * 64,
                         "environment": {"TUNNEL_TOKEN_FILE": "/run/secrets/cloudflared-token"},
                         "command": ["tunnel", "--no-autoupdate", "run"],
                         "secrets": [{"source": "cloudflared-token", "target": "cloudflared-token"}]},
    },
    "secrets": {"cloudflared-token": {"file": str(root / "secrets/cloudflared-token")}},
}
pathlib.Path(sys.argv[1]).write_text(json.dumps(config))
PY
}

change_config() {
  python3 - "$MOCK_CONFIG" "$1" <<'PY'
import json, os, pathlib, sys
path = pathlib.Path(sys.argv[1]); config = json.loads(path.read_text()); case = sys.argv[2]
if case == "ports": config["services"]["frontend"]["ports"] = [{"target": 80, "published": "80"}]
elif case == "extra-service-ports": config["services"]["extra"] = {"ports": ["8081:80"]}
elif case == "host-network": config["services"]["backend"]["network_mode"] = "host"
elif case == "profile": config["services"]["backend"]["environment"]["SPRING_PROFILES_ACTIVE"] = "production,local"
elif case == "cookie": config["services"]["backend"]["environment"]["SECURE_COOKIE"] = "false"
elif case == "db-tag": config["services"]["db"]["image"] = "mariadb:11.4"
elif case == "short-digest": config["services"]["cloudflared"]["image"] = "cloudflare/cloudflared@sha256:abcd"
elif case == "non-hex-digest": config["services"]["cloudflared"]["image"] = "cloudflare/cloudflared@sha256:" + "z" * 64
elif case == "token-env": config["services"]["cloudflared"]["environment"]["TUNNEL_TOKEN"] = os.environ["CANARY"]
elif case == "token-other-env": config["services"]["backend"]["environment"]["TUNNEL_TOKEN"] = os.environ["CANARY"]
elif case == "token-path": config["services"]["cloudflared"]["environment"]["TUNNEL_TOKEN_FILE"] = "/tmp/token"
elif case == "no-secret-mount": config["services"]["cloudflared"]["secrets"] = []
elif case == "wrong-secret-target": config["services"]["cloudflared"]["secrets"][0]["target"] = "other-token"
elif case == "wrong-secret-source": config["secrets"]["cloudflared-token"]["file"] = "/tmp/untrusted-token"
elif case == "external-secret": config["secrets"]["cloudflared-token"]["external"] = True
elif case == "token-argument": config["services"]["cloudflared"]["command"] = ["tunnel", "run", "--token", os.environ["CANARY"]]
elif case == "project": config["name"] = "diku-local"
elif case == "missing-service": del config["services"]["backend"]
elif case == "bad-shape": config["services"]["db"]["environment"] = [os.environ["CANARY"]]
else: raise SystemExit("Unknown test mutation")
path.write_text(json.dumps(config))
PY
}

COUNT=0
assert_run() {
  local expected=$1 code=$2 output status=0
  output=$(bash "$TEST_ROOT/scripts/preflight.sh" 2>&1) || status=$?
  if [[ "$output" == *"$CANARY"* ]]; then printf 'FAIL: secret appeared in captured preflight output.\n' >&2; exit 1; fi
  if [[ -e "$TEST_ROOT/sourced-env" ]]; then printf 'FAIL: env file was executed as shell code.\n' >&2; exit 1; fi
  if [[ "$expected" == pass ]]; then
    [[ "$status" -eq 0 && "$output" == *'OK:'* ]] || { printf 'FAIL: expected successful preflight.\n' >&2; exit 1; }
  else
    [[ "$status" -ne 0 && "$output" == *"[$code]"* ]] || { printf 'FAIL: expected controlled rejection (%s).\n' "$code" >&2; exit 1; }
    [[ "$output" != *'OK:'* ]] || { printf 'FAIL: unsuccessful preflight announced success.\n' >&2; exit 1; }
  fi
  COUNT=$((COUNT + 1))
}

reset_case
assert_run pass ''
grep -q -- '--project-name diku ' "$MOCK_LOG"
[[ $(wc -l < "$MOCK_LOG") -eq 3 ]] || { echo 'FAIL: unexpected Docker action.' >&2; exit 1; }

reset_case; rm "$TEST_ROOT/.env.production"; assert_run fail ENV_MISSING
reset_case; chmod 644 "$TEST_ROOT/.env.production"; assert_run fail ENV_MODE
reset_case; : > "$TEST_ROOT/.env.production"; assert_run fail ENV_EMPTY
reset_case; printf 'DB_PASSWORD="CHANGE_ME_secret"\n' > "$TEST_ROOT/.env.production"; assert_run fail ENV_PLACEHOLDER
reset_case; printf 'TUNNEL_TOKEN=%s\n' "$CANARY" >> "$TEST_ROOT/.env.production"; assert_run fail TOKEN_ENV
reset_case; chmod 755 "$TEST_ROOT/secrets"; assert_run fail SECRETS_MODE
reset_case; rm "$TEST_ROOT/secrets/cloudflared-token"; assert_run fail TOKEN_MISSING
reset_case; printf ' \n\t' > "$TEST_ROOT/secrets/cloudflared-token"; assert_run fail TOKEN_EMPTY
reset_case; printf 'CHANGE_ME_cloudflare_token\n' > "$TEST_ROOT/secrets/cloudflared-token"; assert_run fail TOKEN_PLACEHOLDER
reset_case; printf 'token with spaces\n' > "$TEST_ROOT/secrets/cloudflared-token"; assert_run fail TOKEN_FORMAT
reset_case; chmod 666 "$TEST_ROOT/secrets/cloudflared-token"; assert_run fail TOKEN_MODE
if [[ $(id -u) != 65532 && $(id -g) != 65532 ]]; then
  reset_case; chmod 600 "$TEST_ROOT/secrets/cloudflared-token"; assert_run fail TOKEN_READABILITY
fi
if [[ $(id -u) -eq 0 ]]; then
  reset_case; chown 65532:65532 "$TEST_ROOT/secrets/cloudflared-token"; chmod 600 "$TEST_ROOT/secrets/cloudflared-token"; assert_run pass ''
  reset_case; chown 12345:65532 "$TEST_ROOT/secrets/cloudflared-token"; chmod 640 "$TEST_ROOT/secrets/cloudflared-token"; assert_run pass ''
fi
reset_case; rm "$TEST_ROOT/secrets/cloudflared-token"; ln -s "$TEST_ROOT/.env.production" "$TEST_ROOT/secrets/cloudflared-token"; assert_run fail TOKEN_MISSING

for spec in 'ports PORTS' 'extra-service-ports PORTS' 'host-network PORTS' 'profile PROFILE' 'cookie COOKIE' 'db-tag DIGEST' 'short-digest DIGEST' 'non-hex-digest DIGEST' 'token-env TOKEN_ENV' 'token-other-env TOKEN_ENV' 'token-path TOKEN_FILE' 'no-secret-mount TOKEN_MOUNT' 'wrong-secret-target TOKEN_MOUNT' 'wrong-secret-source TOKEN_SOURCE' 'external-secret TOKEN_SOURCE' 'token-argument TOKEN_ARGUMENT' 'project PROJECT' 'missing-service SERVICES' 'bad-shape CONFIG'; do
  reset_case
  read -r mutation code <<< "$spec"
  change_config "$mutation"
  assert_run fail "$code"
done
reset_case; printf '{invalid json %s' "$CANARY" > "$MOCK_CONFIG"; assert_run fail CONFIG
reset_case; export MOCK_FAILURE=plugin; assert_run fail COMPOSE
reset_case; export MOCK_FAILURE=daemon; assert_run fail DOCKER
reset_case; export MOCK_FAILURE=config; assert_run fail CONFIG
reset_case; export MOCK_FAILURE=partial; assert_run fail CONFIG_CHECK

printf 'PASS: %s isolated preflight cases; fixed project, file permissions, ports, profiles, digests, token mounts, sanitized failures, no env execution.\n' "$COUNT"
