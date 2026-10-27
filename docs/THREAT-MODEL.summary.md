# Threat Model — Summary

- **Surfaces**: local CLI that executes shell commands by design
  (`eval`/`sh -c`) + public stateless landing site (Cloudflare-only
  ingress → nginx TLS → pod as `nobody`, Bandit :8170). No DB/auth/
  sessions/user input.
- **Crown jewels**: the user's tabbing-on state dir (`~/.local/state/
  tabbing`) — the only destructible data — and landing-page availability.
- **Boundaries**: `.demo` file → shell execution (arbitrary by design);
  disk → sourced tabbing-on adapter; internet → edge → pod; CI → registry
  (`REGISTRY_USER`/`REGISTRY_PASSWORD` secrets; `ops-registry-secret`
  pull secret).
- **Register** (8): T-001 medium — arbitrary demo command execution
  (accepted, inherent); T-002 high — state-dir wipe (mitigated: opt-in
  `--reset-state`, prints path, `--dry-run`, contract guard, rust never
  deletes); T-003 low — adapter sourced from XDG paths (accepted, local
  trust); T-004 low — committed dev cookie key (mitigated via
  `SECRET_KEY_BASE` env, sessionless page); T-005 low — JS sourcemap path
  leak (mitigated: maps stripped in image); T-006 low — DoS on landing
  (accepted); T-007 low — rust ignores command exit status (open, parity
  item); T-008 info — unauthenticated `/healthz` (accepted).
- **Coverage**: 3 mitigated · 4 accepted · 1 open. Residual risk is
  deliberate: demo scripts are programs; the landing page holds no data.

Full detail: [THREAT-MODEL.md](THREAT-MODEL.md).
