# ADR-001: Hermes orchestration stack

- Status: accepted for initial sandbox
- Date: 2026-10-20
- Related: [[../Index]]

## Decision

Run the official Hermes Agent image with persistent `/opt/data`, its built-in authenticated dashboard, and OmniRoute as a separate authenticated OpenAI-compatible gateway. Bind host ports to loopback. Keep provider credentials outside images and source control.

Use a typed decision-service boundary. Prototype it locally with Semantic Router/FastEmbed; retain deterministic policy checks for consequential actions. Evaluate hosted Jev behind that boundary later.

## Rationale

- The official Hermes container is more reproducible and safer than executing `curl | bash` on team hosts.
- The built-in Hermes dashboard avoids another mutable dependency for the first version.
- OmniRoute supplies quota-aware routing, fallback and compression, but does not guarantee unlimited use.
- Jev currently presents as hosted early access, not a self-hostable artifact.
- Semantic Router provides a local, low-latency and confidence-aware first step; RouteLLM is narrower and targets model-tier routing.

## Deferred

- Hermes Workspace: attractive third-party workspace, but adds a second UI and shared-volume access before the core stack is proven.
- Jev API integration: pending access, data-governance review and an evaluation set.
- LAN/team exposure: pending TLS reverse proxy, identity provider and backup/restore policy.
