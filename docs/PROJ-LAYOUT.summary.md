# Project Layout — Summary

Quick-reference tree for demo-runner. Full descriptions:
[PROJ-LAYOUT.md](PROJ-LAYOUT.md).

```
demo-runner/
├── shell/bin/demo-runner      # Reference implementation (zsh)
├── rust/                      # Standalone rust port (std-only) — main.rs → demo.rs
├── web/                       # Hologram/Phoenix landing site (app/, lib/, config/, Dockerfile)
├── helm/demo-runner-site/     # Deploy chart (CI-owned image tag)
├── contract-tests/            # Shared fixture corpus + cross-impl harness
├── examples/                  # tour.demo, tabbing-on-tour.demo
├── docs/                      # Layout/arch/schema/threat-model docs + summaries
├── .github/workflows/ci.yml   # test + smoke on push; image + chart bump on main
├── .meta/pointers.yaml        # doc-pointer store
├── Makefile                   # compile/test/install/doctor
├── CHANGELOG.md
├── README.md
└── LICENSE
```

- No database, no KV store, no persistence (see [PROJ-SCHEMA.md](PROJ-SCHEMA.md)).
- Generated, gitignored: `web/deps/`, `web/_build/`, `web/priv/static/hologram/`, `rust/target/`.
