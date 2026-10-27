# Project Schema — Summary

- **No relational store, no KV, no persistence.** CLIs are stateless; the
  site is sessionless SSR (deps: phoenix, bandit, jason, hologram — no
  ecto/db). ERD guidance n/a.
- **Primary data format** — `.demo` grammar: `#`/`##` headings, `$`
  typed-then-executed commands, `@sleep`/`@input`/`@prompt`/`@clear`
  (+ rust-only `@speed`), blank/verbatim passthrough. Classification
  order identical in both implementations.
- **Contract expectations** — `.expect` lines: `contains:<substring>` or
  `file:<path>=<content>`; harness normalizes ANSI/blank lines and runs
  both impls in an `env -i` sandbox.
- **Config surfaces** — `web/config/` layering (config.exs → prod-only
  runtime.exs → test.exs); env vars: `BIND_IP`, `PORT`, `PHX_HOST`,
  `SECRET_KEY_BASE`, `HOLOGRAM_START`, `HOLOGRAM_ENV`;
  `DEMO_RUNNER_SPEED`/`TABBING_DEMO_SPEED`, `TABBING_ROOT`,
  `XDG_DATA_HOME`, `XDG_STATE_HOME`. Helm `values.yaml`: CI-owned
  `sha-<7>` image tag, port 8170, `ops-registry-secret`,
  `therrobotlives-com-tls`, cloudflare-only nginx ingress.
- **Interfaces** — `GET /healthz` → `200 ok`; `GET /` (SSR landing);
  static `/assets` + `/hologram`; image tags `:sha-<7>` on
  `ops.noizu.com`.

Full detail: [PROJ-SCHEMA.md](PROJ-SCHEMA.md).
