# Project Layout

Navigable map of the demo-runner repository. Honest scale note: this is a
small repo — two CLI implementations (~800 lines combined), a single-page
Hologram landing site, one helm chart, and the CI that ships it. Each
artifact owns a top-level directory; there is no shared `src/` monolith.

## Tree

```
demo-runner/
├── shell/
│   └── bin/demo-runner            # Reference implementation (zsh) — the complete .demo player
├── rust/
│   ├── Cargo.toml                 # Crate manifest — std-only, zero dependencies
│   ├── Cargo.lock                 # Lockfile (empty dependency graph)
│   └── src/
│       ├── main.rs                # Entry point — argv passthrough to demo::run_demo
│       └── demo.rs                # Rust player — line classifier, typewriter output, sh -c execution, unit tests
├── web/                           # Landing site (Elixir/Phoenix/Hologram) — see notes below
│   ├── app/                       # Hologram layer — pages/home_page.ex + .holo template, main_layout.ex
│   ├── lib/demo_runner_web/       # Phoenix layer — endpoint.ex, router.ex (GET /healthz), controllers/health.ex, application.ex, error_html.ex
│   ├── config/                    # config.exs (compile-time) · runtime.exs (prod env) · test.exs
│   ├── priv/static/assets/        # Committed static assets — site.css, favicon.svg
│   ├── test/                      # ExUnit suite (endpoint/controller tests)
│   ├── mix.exs / mix.lock         # Deps: phoenix 1.8, bandit, jason, hologram 0.10 — no DB, no auth
│   ├── Dockerfile                 # Multi-stage: build (Node 22 + hex) → mix release → production (USER nobody)
│   ├── COPY.md                    # Landing-page copy — source of truth for page text
│   └── .tool-versions             # Elixir/OTP pins (CI reads strict)
├── helm/demo-runner-site/         # Deploy chart — deployment/service/ingress templates + values.yaml (CI-owned image tag)
├── contract-tests/
│   ├── fixtures/                  # Shared corpus: 4 × (.demo script + .expect assertions)
│   └── run.sh                     # Cross-implementation harness — env -i sandbox, normalized diff, state-wipe guard
├── examples/
│   ├── tour.demo                  # Standalone tour of the .demo format
│   └── tabbing-on-tour.demo       # Demo driving tab titles (needs optional tabbing-on)
├── docs/                          # This documentation set (layout/arch/schema/threat-model + summaries)
├── .github/workflows/ci.yml       # tool-test · web-test · smoke · build-push · bump-chart · ci-timing
├── .meta/pointers.yaml            # doc-pointer store (UUID-keyed source anchors)
├── Makefile                       # compile · test · contract-test · install · doctor · clean
├── CHANGELOG.md                   # Dated work log
├── README.md                      # Start here — format, install, usage, parity matrix
└── LICENSE                        # MIT
```

## Generated / gitignored (not source — never document as code)

| Path | Why |
|---|---|
| `web/deps/`, `web/_build/` | mix fetch + build outputs |
| `web/priv/static/hologram/` | Hologram client bundles — regenerated in-image at compile; gitignored because generated `.js.map` files embed build-machine paths (the Dockerfile strips the maps) |
| `rust/target/` | cargo build output |
| `.claude/worktrees/` | agent worktrees |

## Key files

| File | Role / action |
|---|---|
| `shell/bin/demo-runner` | The product — canonical behavior lives here (extensionless zsh script) |
| `web/config/runtime.exs` | Only env-driven config surface — `BIND_IP`, `PORT`, `PHX_HOST`, `SECRET_KEY_BASE` |
| `helm/demo-runner-site/values.yaml` | Image tag is CI-owned (`bump-chart`); never bump by hand |
| `contract-tests/fixtures/` | Behavior contract shared by both implementations — change with care, both impls must match |

No setup-required dotfiles: no `.envrc`/`.env.example` exist in this repo;
the runtime environment variables are documented in
[PROJ-SCHEMA.md](PROJ-SCHEMA.md).
