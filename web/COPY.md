# demo-runner — Landing Copy Deck

Page: single route `/` at **demo-runner.therobotlives.com** · implemented in `web/` (Elixir Hologram)
Sources of truth: repo `README.md` (format reference, usage/flags, feature-parity matrix,
tabbing-on integration, install), `Makefile` (real targets), `examples/tour.demo`,
`examples/tabbing-on-tour.demo`, `contract-tests/run.sh` + `fixtures/` (contract + state-wipe
guard), `shell/bin/demo-runner`, `rust/src/main.rs` + `rust/src/demo.rs`, `LICENSE` (MIT) —
every claim below is repo-verifiable as of commit `e16460f` (main, 2026-10-12, the published HEAD).

**Design note (bypass):** no hero art / media-generation mockup loop — mirrors the run-claude
and direnv-config landings: example-led typography IS the design, dark-first, monospace-forward.
The hero's visual is the real install sequence and a real `.demo` script, not an illustration.

**Scrub note:** page examples use neutral names (`proof.txt`, "the example site"). The provenance
link to github.com/noizu/tabbing-on and the clone URL github.com/noizu/demo-runner are the real
public repos and appear deliberately. No secret values appear anywhere.

**Bundle note (public repo):** the sibling landings (run-claude, direnv-config — private org
repos) commit the generated `priv/static/hologram/*` bundles. This repo does NOT: the
generated `.js.map` files embed the build machine's absolute checkout path inside
`sourcesContent`, and every `HOLOGRAM_START=1` compile rewrites them — committing them would
publish a local path and go stale the moment anyone rebuilds. They are gitignored; the Docker
build regenerates them in-image (`mix compile` runs after `COPY priv`), and local dev gets
them from the first `HOLOGRAM_START=1 mix compile`. This is the one deliberate structural
deviation from the siblings.

**Dev note:** dev/test builds need `HOLOGRAM_START=1` — without it the Hologram compiler
no-ops (no `priv/static/hologram` bundles) and `/` 404s. Use `HOLOGRAM_START=1 mix compile`
and `HOLOGRAM_START=1 mix test`. Prod pins `HOLOGRAM_ENV=prod` (and `HOLOGRAM_START=1`) in the
Dockerfile — the same gate as every other Hologram site in the fleet; the runtime must set the
env explicitly or the Hologram router disables itself and every page 404s.

---

## 1. JTBD summary

| Question | Answer |
|---|---|
| Trigger | You need to demo a terminal tool — a screencast, a live walkthrough, a docs tour — and ad-hoc "type slowly while talking" fails: you typo, you drift, and you cannot reproduce it next week. |
| Job | Write the demo once as a plain-text `.demo` script and replay it live any number of times, at any speed, with every command actually executing. |
| Today's alternative | demo-magic sourced into a bespoke bash script; doitlive for interactive replay; Charm's VHS for rendered GIFs; or typing it live and hoping. |
| What's wrong with that | Bespoke scripts couple demo content to demo mechanics and die in a drawer; doitlive needs you at the keys; VHS renders a movie, not a live terminal; typing live is unrepeatable. |
| Switch trigger | The second time you fumble the same live demo — or the first time someone asks "can you run that again, slower?" |
| Objections | "Does it actually execute?" · "Which implementation do I use?" · "Will it delete anything?" · "Do I need tabbing-on?" · "Why not VHS?" |

## 2. Positioning statement (Dunford form)

> For developers who demonstrate terminal tools live, demo-runner is a scripted demo player
> that reads a plain-text `.demo` file and replays it as a typewriter session — headings appear
> instantly, commands are typed character-by-character and then actually executed, with
> `@`-directives for pacing and speed control. Unlike demo-magic's script-embedded helpers,
> doitlive's keystroke-by-keystroke interactivity, and VHS's rendered-to-file movies,
> demo-runner keeps the demo as data: write once, replay at any speed, real side effects,
> no runtime dependency beyond zsh.

## 3. Category POV (for launch posts, not the page)

- **Enemy:** the unreproducible demo — terminal walkthroughs that exist only in the moment they are typed, and bespoke demo scripts nobody can replay but their author.
- **Shift:** a demo is data, not a performance. Text in, live terminal out.
- **New way:** author the walkthrough as a `.demo` file; let the player handle typing, pacing, headings and clears; retune speed per audience.
- **Proof:** `make test` runs both implementations over a shared fixture corpus and asserts identical normalized output plus real command side effects; the state-wipe guard pins "a plain run never deletes user state".

## 4. Message hierarchy

| Level | Copy |
|---|---|
| **Tagline** (≤7 words) | Write the demo once. Replay it live. |
| **One-liner** | demo-runner reads a `.demo` script and plays it back like a human operator: headings appear instantly, `$ command` lines are typed character-by-character then actually executed, and `@sleep`/`@input`/`@prompt`/`@clear` directives pace the show. |
| **Paragraph** | A typewriter-style scripted terminal demo player for recording polished demos, screencast rehearsals, and live walkthroughs. Two implementations ship: a zsh reference (canonical, complete) and a lean std-only Rust port of the core format — the parity matrix is lopsided and shown honestly. Speed control comes from `--fast`/`--slow`/`--speed` flags or the `DEMO_RUNNER_SPEED` env var (shell only). Nothing is ever deleted by default: the single destructive flag, `--reset-state`, is opt-in, prints its target path first, and has `--dry-run` — pinned by contract tests. Extracted from noizu/tabbing-on; the integration is optional and feature-detected. |
| **Benefit pillars** | Demos as data · Real execution, real side effects · Safe by default |
| **Proof points** | Full format reference + parity matrix in README · cross-implementation contract tests incl. three state-wipe guard cases · zero runtime deps (zsh / Rust std only, no crates) |

## 5. Landing-page copy block (final copy, implemented verbatim)

### SEO head

- **title:** `demo-runner — Write the demo once. Replay it live.`
- **meta description:** `demo-runner is a typewriter-style scripted terminal demo player: a plain-text .demo script becomes a live playback — headings appear instantly, $ commands are typed character-by-character then actually executed, with @sleep/@input/@prompt/@clear directives and speed control. zsh reference implementation plus a Rust port, contract-tested, MIT licensed.`

### Hero

- **Eyebrow:** `Typewriter-style scripted terminal demo player · zsh + Rust · MIT`
- **Headline:** `Write the demo once. Replay it live.`
- **Subhead:** demo-runner reads a `.demo` script and plays it back like a human operator: `#` and `##` headings appear instantly, `$ command` lines are typed out character-by-character — then actually executed. `@sleep`, `@input`, `@prompt` and `@clear` pace the show; `--fast`, `--slow` and `--speed` retune it.
- **Primary CTA:** button `Install from source` → `#install`; adjacent copy-paste block:

  ```bash
  # Prerequisites: zsh for the shell reference implementation;
  # a Rust toolchain only for the Rust port; asciinema optional
  git clone https://github.com/noizu/demo-runner && cd demo-runner

  make install            # builds rust (if cargo present) and installs both
  make install-shell      # shell reference only — no Rust toolchain needed
  make doctor             # check toolchain prerequisites and integration status
  make check              # verify installed binaries respond
  ```

- **Install honesty line:** `demo-runner is not on Homebrew, crates.io, or npm — there is no
  one-liner and no curl | sh. Packaged installs are planned, not available. Installs land at
  ~/.local/bin/demo-runner (shell, reference) and ~/.local/bin/demo-runner-rs (rust).`
- **CTA fine print:** `Commands really execute · nothing is deleted by default · MIT licensed`
- **Secondary CTA:** `The .demo format` → `#format`
- **Then-play-the-tour block:** bare `demo-runner` (default script `examples/tour.demo`),
  `demo-runner examples/tour.demo`, `demo-runner-rs examples/tour.demo`,
  `demo-runner examples/tabbing-on-tour.demo # needs tabbing-on`.

### Benefit blocks ×3

1. **Demos as data.** A demo is a plain-text `.demo` file — diffable, versionable,
   hand-editable. Headings and narrative render instantly; commands type out with human
   jitter. Write it once, replay it next week at any speed.
2. **Real execution.** `$` lines run for real — `eval` in your zsh (reference) or `sh -c`
   (rust). Contract fixtures assert that files created by demo commands actually exist
   afterwards. Pauses after commands and headings keep viewers with you.
3. **Safe by default.** Nothing is deleted unless you pass `--reset-state` — opt-in, prints
   the absolute path first, `--dry-run` available. Pinned by contract tests, not by promise.

### The .demo format

The README's format reference table (9 line types) verbatim, an example script block
(neutral: `# Deploying the example site`, `$ make test`, `@sleep 1`, `@prompt`, `proof.txt`),
and the playback flags block (`--fast`, `--slow`, `--speed medium`, `--no-pause` shell-only)
plus the `DEMO_RUNNER_SPEED` / `TABBING_DEMO_SPEED` env-var note (shell only).

### Parity matrix (the load-bearing honesty section)

Section heading: **Two implementations, one reference**. The page states the asymmetry in
prose before the table: the shell reference carries **12** capabilities the Rust port lacks;
the Rust port adds **exactly one** the shell lacks (inline `@speed`) plus one cosmetic
difference (an extra blank line after each command). The full 26-row matrix from the README
renders in three groups — shared core (12 rows), Reference-only (12 rows), Rust-only
(2 rows) — with Yes/No tags colour-coded but never colour-only. Small print retained:
fast = 10 ms/char shell vs 15 ms/char rust; unknown `--speed` falls back to medium in shell,
exits 1 in rust.

### Safety section

Section heading: **Nothing is deleted by default — ever**. Three cards: (1) the default run
touches nothing — the only destructive path is `--reset-state`, integration-only, deletes
`${XDG_STATE_HOME:-~/.local/state}/tabbing`; (2) destruction is opt-in, loud and
previewable — prints the absolute path before deleting, irreversible with no backup
mechanism, `--dry-run` prints-and-deletes-nothing (on its own it has no effect; demo
commands still execute); (3) pinned by contract tests — the three guard cases
(`no-flag-keeps-state`, `reset-state-deletes`, `reset-state-dry-run-keeps`) with a stub
tabbing adapter so the reset path genuinely activates. Footer note gives the honest history:
the shell implementation once wiped the state dir unconditionally (fixed in `e16460f`);
"a test that fails when the default changes is" the safety property.

### Neighbours table

`demo-runner and its neighbours` — demo-magic (helpers sourced into your script; demo-runner
keeps the demo as data), doitlive (interactive, you at the keys; demo-runner plays
autonomously), VHS (renders .tape to GIF/video headless; demo-runner is live in your real
terminal with real side effects; asciinema .cast playback via the optional integration).
Caption: extraction provenance (noizu/tabbing-on, `bin/demo-runner`), optional
feature-detected integration, silent degradation, contract suite runs without it.

### FAQ (objection row)

1. **Does it really execute the commands?** Yes — `eval` (zsh reference) / `sh -c` (rust);
   side effects are genuine and contract-asserted. Treat a `.demo` script like a shell
   script: read it before you run it.
2. **Which implementation should I use?** The zsh reference — the matrix is lopsided in its
   favour. Rust if you want a lean std-only core build plus inline `@speed`.
3. **Is this demo-magic, doitlive, or VHS?** No — see the table.
4. **Will it delete anything?** No — never by default; opt-in `--reset-state` prints first;
   `--dry-run`; pinned by guard tests.
5. **Do I need tabbing-on?** No — no hard dependency; standalone mode is a contract test,
   not a claim.
6. **How do I install it?** Clone + make (zsh prereq up front; Rust toolchain only for the
   rust port; asciinema only for recording playback). Not on any package manager; packaged
   installs are planned.
7. **What's the license?** MIT — same license and author as tabbing-on.

### Final CTA

`Write the demo once. Replay it live.` · install block (`git clone … && cd demo-runner`,
`make compile && make test`, `make install && make doctor`) · button `Install from source`.

### Footer

`demo-runner — a noizu.com project` · GitHub: `github.com/noizu/demo-runner` ·
`MIT licensed` · `This site is Elixir Hologram.` · © 2026

---

## 6. Repo-verifiable claims (all against commit `e16460f`, the published main HEAD)

| # | Claim on page | Verified in |
|---|---|---|
| 1 | Typewriter playback: headings instant, `$` typed char-by-char then executed | `README.md`, `shell/bin/demo-runner`, `rust/src/demo.rs` |
| 2 | Format table: `#`, `##`, `$`, `@sleep N` (fractional), `@input`, `@prompt`, `@clear`, blank, verbatim | `README.md` format reference; parser in `rust/src/demo.rs` (Sleep/Prompt/Input/Clear/SpeedChange) |
| 3 | `@speed fast\|medium\|slow` inline directive is rust-only | `rust/src/demo.rs` (`SpeedChange`), absent from `shell/bin/demo-runner` |
| 4 | `--fast` / `--slow` / `--speed` flags in both | `shell/bin/demo-runner` case block, `rust/src/demo.rs` run_demo |
| 5 | `DEMO_RUNNER_SPEED` env var, `TABBING_DEMO_SPEED` compat, shell only | `shell/bin/demo-runner`, `README.md` |
| 6 | `--no-pause` shell only | `shell/bin/demo-runner` (`--no-pause`), absent from rust arg loop |
| 7 | Parity matrix: 12 shell-only rows, 1 rust-only feature + cosmetic blank-line difference | `README.md` feature parity matrix (counted row by row) |
| 8 | Small print: fast = 10 ms/char shell vs 15 ms/char rust; unknown speed falls back vs exits 1 | `README.md` matrix footnote, `rust/src/demo.rs` (exits on unknown speed) |
| 9 | Shell aborts when a demo command fails (`set -e`); rust ignores exit status | `README.md` matrix; `shell/bin/demo-runner` |
| 10 | Default script `examples/tour.demo` (shell only; rust requires a path) | `README.md`, `shell/bin/demo-runner` |
| 11 | Never deletes by default; `--reset-state` opt-in, prints absolute path first; `--dry-run` prints without deleting; `--dry-run` alone has no effect | `shell/bin/demo-runner` (`_DEMO_RESET_STATE=0` default; print-then-delete block), `README.md` |
| 12 | State dir is `${XDG_STATE_HOME:-~/.local/state}/tabbing` (history, todos, recordings) | `README.md`, `contract-tests/run.sh` guard |
| 13 | Three state-wipe guard cases incl. "a plain run must never delete user state" | `contract-tests/run.sh` (`guard_case no-flag-keeps-state 3 0`, `reset-state-deletes 0 1`, `reset-state-dry-run-keeps 3 1`) |
| 14 | The unconditional wipe existed and `e16460f` made it opt-in | `contract-tests/run.sh` history comment; commit `e16460f` message |
| 15 | Contract tests: shared fixture corpus, both implementations, scrubbed env (no TABBING_ROOT), `.expect` assertions, real side effects | `contract-tests/run.sh` header + `fixtures/*` |
| 16 | No hard tabbing-on dependency; feature-detected; silent degradation; helpers no-op without it | `README.md` integration section, `shell/bin/demo-runner` adapter lookup |
| 17 | asciinema playback via helper (`_tabbing_demo_play_recording`), rust lacks it | `shell/bin/demo-runner` usage line (asciinema play), `README.md` matrix |
| 18 | Install: `make install`, `make install-shell`, `make doctor`, `make check`; dev targets `compile`, `test`, `contract-test`; installs to `~/.local/bin/demo-runner{,-rs}` | `Makefile` |
| 19 | Prereqs: zsh (shell), cargo (rust only), asciinema (optional recordings) | `README.md` prerequisites, `Makefile` doctor |
| 20 | Not on any package manager; no one-liner/curl\|sh; packaged installs planned | `README.md` install honesty |
| 21 | Extracted from noizu/tabbing-on where it lived as `bin/demo-runner`; same MIT license, same author | `README.md` provenance, `LICENSE` |
| 22 | Rust crate is std-only, no dependencies | `rust/Cargo.toml` (no `[dependencies]` section) |
| 23 | Clone URL github.com/noizu/demo-runner (public repo, this PR's base) | `gh repo view noizu/demo-runner` → PUBLIC |

## Voice rules

- Dev-tool, example-led, zero fluff. Every claim names a mechanism or a file.
- No invented metrics, no testimonials, no user logos. Counts (12 / 1) are row counts from the
  README matrix, done by hand against the published commit.
- Never oversell install: it is clone + make, prerequisites stated up front, "planned" stays
  planned — no package-manager mention without the "not available" qualifier.
- Never imply the two implementations are equivalent: the lopsided count is stated in prose
  before the table renders.
- Never describe any wipe as automatic or default: the sentence pattern is "never deletes
  anything unless you pass --reset-state".
- The competitive reads name demo-magic, doitlive and VHS accurately — what each does, and the
  one axis where demo-runner differs — without trashing them.
