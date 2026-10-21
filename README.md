# Kobol Hermes sandbox

Reproducible, team-shareable Docker stack for Hermes Agent, OmniRoute, an official Codex CLI sidecar and Redis. Hermes uses its official dashboard for the visual interface and calls OmniRoute through the private Compose network.

## Architecture

```text
Browser -> Hermes dashboard :9119 -> Hermes gateway :8642
                                      |
                                      v
                              OmniRoute :20128 -> configured GPT/other providers
                                      |
                         +------------+------------+
                         v                         v
               Codex app-server                Redis
               (ChatGPT OAuth)
```

All host ports bind to `127.0.0.1` by default. Hermes and OmniRoute require authentication. Persistent state lives in Docker named volumes; secrets live only in the untracked `.env` file.

## Start

```bash
./scripts/init-env.sh
./scripts/bootstrap.sh
```

Alternatively, copy `.env.example` manually when secrets are managed by your team's vault.

Open `http://127.0.0.1:20128`, finish OmniRoute onboarding, connect an authorized provider/account, and create the API key copied into `OMNIROUTE_API_KEY`. Then:

```bash
./scripts/configure-hermes.sh
docker compose ps
```

Open Hermes at `http://127.0.0.1:9119`. Its OpenAI-compatible API is at `http://127.0.0.1:8642/v1`.

## GPT for planning and orchestration

Configure a GPT-capable provider in OmniRoute and make the desired GPT model (or a combo ending in it) the `auto` route. Hermes sees OmniRoute as a named OpenAI-compatible provider. Provider terms, quotas and rate limits still apply: OmniRoute aggregates routes and performs fallback/compression; it cannot create genuinely unlimited tokens.

For direct OpenAI use without OmniRoute, run `docker compose exec hermes hermes model`, choose OpenAI or OpenAI Codex, and follow the interactive authentication flow. This changes the persistent Hermes configuration.

### Existing ChatGPT Plus/Pro subscription

In OmniRoute choose **OpenAI Codex (App-Server)** and **Sign in with ChatGPT**. The sidecar runs the official Codex CLI, stores OAuth in its own Docker volume and refreshes it normally. Do not choose the legacy `codex` connection that replays an OAuth token through the proxy. A ChatGPT subscription has usage limits and any optional ChatGPT credits remain separate from API credits.

## Local decision layer

Jev is a hosted early-access System One model: structured decisions with confidence, not a locally downloadable model. The closest practical local-first path is `semantic-router>=1` with FastEmbed. It runs locally, supports calibrated confidence and exposes a future upgrade path to Jev through its `DecisionRouter`.

Recommended rollout:

1. Start with deterministic rules for security/approval boundaries.
2. Add a local Semantic Router sidecar for intent, tool and model selection.
3. Log decisions, confidence and human corrections.
4. Calibrate on team traffic before allowing autonomous high-impact branches.
5. Evaluate Jev behind the same typed decision interface when access and data-policy review are complete.

RouteLLM is a better fit when the only decision is weak-vs-strong model selection. SetFit is a good later choice when the team has labeled examples and needs a custom local classifier.

See [the architecture decision](work/active/ADR-001-hermes-stack.md) for rationale and deferred options.

## Operations

```bash
docker compose logs -f hermes omniroute
docker compose pull && docker compose up -d
docker compose down                 # keeps data volumes
```

Do not run `docker compose down -v` unless permanent deletion of Hermes memory, OmniRoute configuration and Redis data is intended.
