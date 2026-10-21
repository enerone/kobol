#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
host_auth="${CODEX_HOME:-$HOME/.codex}/auth.json"
container_name="$(cd "$repo_dir" && docker compose ps -q codex-app-server)"

if [[ ! -f "$host_auth" ]]; then
  echo "No Codex auth found at $host_auth. Run 'codex login' on the host first." >&2
  exit 1
fi

if [[ -z "$container_name" ]]; then
  echo "The codex-app-server container is not running. Run ./scripts/bootstrap.sh first." >&2
  exit 1
fi

docker cp "$host_auth" "$container_name:/home/node/.codex/auth.json"
docker compose -f "$repo_dir/compose.yaml" exec -T codex-app-server \
  sh -lc 'chown node:node /home/node/.codex/auth.json && chmod 600 /home/node/.codex/auth.json'
docker compose -f "$repo_dir/compose.yaml" restart codex-app-server
docker compose -f "$repo_dir/compose.yaml" exec -T codex-app-server \
  runuser -u node -- codex login status
