# Project Architecture — Summary

- **What**: typewriter-style scripted terminal demo player — plays a
  `.demo` file like a human operator (headings instant, `$` commands typed
  then really executed, `@`-directives for pauses/input/prompts/clears).
- **Three artifacts**: (1) two implementations of one format — zsh
  reference (`shell/`) + rust port (`rust/`), pinned by `contract-tests/`;
  (2) server-rendered Hologram landing site (`web/`) — no DB, no auth, one
  page + `/healthz`; (3) helm chart + CI that publish `sha-*` images on
  `main`, bump the chart tag, and ArgoCD-sync to the cluster.
- **Data flow**: prefix classifier (`##` → `#` → `$` → `@…` → blank →
  verbatim), identical in both impls. Shell impl `eval`s in the current
  zsh (`set -e`); rust impl spawns `sh -c`, ignores exit status.
- **Key decisions**: reference + port locked by a shared fixture corpus;
  `--reset-state` state wipe is opt-in, path-printing, dry-runnable,
  contract-guarded (upstream wiped unconditionally — that bug is why the
  flag exists); rust is std-only; chart image tags are CI-owned.
- **Release path**: PRs → `develop`; releases `develop` → `stage` →
  `main` (regular merges); `main` push = image to
  `ops.noizu.com/...:sha-<7>` + chart bump + ArgoCD sync.

Full detail: [PROJ-ARCH.md](PROJ-ARCH.md).
