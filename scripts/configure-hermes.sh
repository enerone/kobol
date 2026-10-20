#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_dir"

if [[ ! -f .env ]] || grep -Eq '^[^#]*=.*CHANGE_ME' .env; then
  echo "Create .env and replace every CHANGE_ME value first." >&2
  exit 1
fi

docker compose run --rm --no-deps \
  -v "$repo_dir/config:/bootstrap:ro" \
  hermes sh -lc 'if [ ! -f /opt/data/config.yaml ]; then cp /bootstrap/hermes-omniroute.yaml /opt/data/config.yaml; fi'
docker compose up -d hermes

echo "Hermes dashboard: http://127.0.0.1:${HERMES_DASHBOARD_PORT:-9119}"
echo "Hermes API health: http://127.0.0.1:${HERMES_API_PORT:-8642}/health"
