#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_dir"

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Created .env. Replace every CHANGE_ME value, then run this script again." >&2
  exit 1
fi

if grep -Eq '^[^#]*=.*CHANGE_ME' .env; then
  echo ".env still contains CHANGE_ME values." >&2
  exit 1
fi

docker compose config --quiet
docker compose pull
docker compose up -d redis omniroute

echo "OmniRoute is starting; run 'docker compose port omniroute 20128' for its host address."
echo "Complete provider onboarding and create the OMNIROUTE_API_KEY from .env."
echo "Then run: ./scripts/configure-hermes.sh"
