# Project Schema

**No relational store.** demo-runner has no database, no KV store, and no
persistence layer anywhere: the CLIs are stateless players (the only
on-disk touch is the opt-in `--reset-state` deletion of tabbing-on's state
dir), and the site is sessionless SSR with no DB dependency in
`web/mix.exs`. The ERD guidance therefore does not apply; this document
covers the data that does exist: the `.demo` script format, the
contract-test expectation format, configuration surfaces, fixtures, and
the HTTP interface.

→ *Directory map: [PROJ-LAYOUT.md](PROJ-LAYOUT.md) · runtime behavior:
[PROJ-ARCH.md](PROJ-ARCH.md)*

## `.demo` script format (primary data)

A `.demo` file is UTF-8 text, one directive per line. Classification order
matters (`##` must win over `#`) and is identical in both implementations.

| Line | Behavior | shell | rust |
|---|---|---|---|
| `# text` | Bold cyan heading + underline, instant | Yes | Yes |
| `## text` | Dim description, instant | Yes | Yes |
| `$ command` | Typed char-by-char, then executed (`eval` / `sh -c`) | Yes | Yes |
| `@sleep N` | Pause N seconds (fractions allowed) | Yes | Yes |
| `@input TEXT` | Simulate typed stdin (visual only — not piped) | Yes | Yes |
| `@prompt [TEXT]` | Pause for Enter (shell reads `/dev/tty`; rust reads stdin) | Yes | Yes |
| `@clear` | Clear screen (`clear` / inline ANSI) | Yes | Yes |
| `@speed fast\|medium\|slow` | Inline speed change | No | Yes |
| *(blank line)* | Blank line | Yes | Yes |
| *(anything else)* | Verbatim | Yes | Yes |

Inventory: `examples/tour.demo` (standalone),
`examples/tabbing-on-tour.demo` (needs tabbing-on),
`contract-tests/fixtures/*.demo` (corpus).

## Contract-test expectation format

`contract-tests/fixtures/<name>.expect`, one assertion per line (`#`
comments and blank lines ignored):

| Pattern | Meaning |
|---|---|
| `contains:<substring>` | fixed-string substring must appear in normalized output |
| `file:<path>=<content>` | file must exist in the sandbox cwd with exact content |

Normalization: ANSI CSI stripped, trailing whitespace stripped, all blank
lines removed (the rust impl legitimately prints one extra blank line
after commands). Harness `contract-tests/run.sh`: `env -i` sandbox,
per-fixture exit-0 + cross-impl identical output + expectations, then a
`--reset-state` state-wipe guard section.

## Configuration

### Layering (web/)

`config.exs` (compile-time defaults) → `runtime.exs` (prod-only overrides,
evaluated by the release config provider) → `test.exs` (test env; no HTTP
listener).

### Environment variables

| Variable | Read by | Default | Purpose |
|---|---|---|---|
| `BIND_IP` | `web/config/runtime.exs` (prod) | `0.0.0.0` | HTTP bind address; malformed values fall back to the default |
| `PORT` | `web/config/runtime.exs` (prod) | `8170` | HTTP port; invalid/out-of-range values fall back to 8170 |
| `PHX_HOST` | `web/config/runtime.exs` (prod) | `demo-runner.therrobotlives.com` | URL host |
| `SECRET_KEY_BASE` | `web/config/runtime.exs` (prod) | committed dev default in `config.exs` | Cookie-signing secret; deployments rotate via env |
| `HOLOGRAM_START` | web runtime / CI | unset | `1` required or Hologram routes 404 |
| `HOLOGRAM_ENV` | web runtime (image pins `prod`) | falls back to `:dev` in releases | Gates the Hologram router |
| `DEMO_RUNNER_SPEED` | shell impl | `medium` | Default typing speed |
| `TABBING_DEMO_SPEED` | shell impl | — | Legacy alias of the above |
| `TABBING_ROOT` | shell impl | — | Explicit tabbing-on checkout root (adapter lookup order 1) |
| `XDG_DATA_HOME` | shell impl | `~/.local/share` | tabbing-on adapter lookup order 2 |
| `XDG_STATE_HOME` | shell impl | `~/.local/state` | tabbing state dir — deleted ONLY by `--reset-state` |

### Helm values (`helm/demo-runner-site/values.yaml`)

| Key | Value / meaning |
|---|---|
| `fullnameOverride` | `demo-runner-site` |
| `domain` | `demo-runner.therrobotlives.com` |
| `replicas` | `1` |
| `image` | `ops.noizu.com/demo-runner.therrobotlives.com/web:sha-<7>` — CI-owned (`bump-chart`) |
| `port` | `8170` |
| `imagePullSecrets` | `ops-registry-secret` |
| `resources` | requests 50m CPU / 128Mi; memory limit 512Mi |
| `tls.secretName` | `therrobotlives-com-tls` (zone origin CA; Infisical TLS disabled) |
| `ingress` | nginx class, `cloudflareOnly: true`, ssl-redirect |

## Fixtures & data files

| Path | Format | Purpose |
|---|---|---|
| `examples/*.demo` | `.demo` grammar | Runnable demos |
| `contract-tests/fixtures/*.demo` + `.expect` | grammars above | Cross-implementation corpus |
| heredoc inside `shell/bin/demo-runner` | asciicast v2 JSON | Minimal sample `.cast` written by `_tabbing_demo_create_sample_cast` (integration mode) |

## Interfaces

| Interface | Shape | Notes |
|---|---|---|
| `GET /healthz` | `200` text `ok` | Liveness/readiness for k8s probes + Docker `HEALTHCHECK` |
| `GET /` | Hologram SSR HTML | Single landing page (Hologram router mounted before the Phoenix router) |
| `GET /assets/*`, `/hologram/*` | static files | Committed assets + generated Hologram client bundles |
| image contract | `:sha-<7>` tags | Published to `ops.noizu.com` on `main` pushes only |

## Timestamps

Not applicable — no tables, no persisted records; the only timestamps in
the repo are doc-pointer store metadata (`.meta/pointers.yaml`).
