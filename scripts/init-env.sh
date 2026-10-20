#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
env_file="$repo_dir/.env"

if [[ -e "$env_file" ]]; then
  echo "$env_file already exists; leaving it unchanged."
  exit 0
fi

umask 077
dashboard_password="$(openssl rand -hex 24)"
hermes_api_key="$(openssl rand -hex 32)"
omniroute_api_key="$(openssl rand -hex 32)"
omniroute_password="$(openssl rand -hex 24)"
bridge_secret="$(openssl rand -hex 32)"

sed \
  -e "s/CHANGE_ME_LONG_RANDOM_API_KEY/$hermes_api_key/" \
  -e "0,/CHANGE_ME_LONG_RANDOM_PASSWORD/s//$dashboard_password/" \
  -e "s/CHANGE_ME_OMNIROUTE_API_KEY/$omniroute_api_key/" \
  -e "0,/CHANGE_ME_LONG_RANDOM_PASSWORD/s//$omniroute_password/" \
  -e "s/CHANGE_ME_LONG_RANDOM_SECRET/$bridge_secret/" \
  "$repo_dir/.env.example" > "$env_file"

echo "Created $env_file with mode 0600 and generated local secrets."
