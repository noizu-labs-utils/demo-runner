# demo-runner

A typewriter-style scripted terminal demo player. It reads a `.demo` script
and plays it back like a human operator: `#` and `##` headings appear
instantly, `$ command` lines are typed out character-by-character and then
actually executed, and `@`-directives add pauses, simulated input, prompts
and screen clears.

Use it to record polished terminal demos, screencast rehearsals, or live
walkthroughs: write the demo once as a text file, replay it any number of
times, at any speed.

**Extracted from [noizu/tabbing-on](https://github.com/noizu/tabbing-on)**,
where it lived as `bin/demo-runner`. It is now self-contained; the
tabbing-on integration is optional (see below). Same MIT license, same
author.

- `shell/` — the zsh implementation. **Reference implementation**: canonical
  and complete.
- `rust/` — a Rust implementation, standalone binary. Leaner and faster to
  start, but not yet at feature parity — see the matrix below.

## The `.demo` format

| Line prefix | Behavior |
|---|---|
| `# text` | Bold cyan heading with underline (appears instantly) |
| `## text` | Dim description (appears instantly) |
| `$ command` | Typed out char-by-char, then executed (shell: `eval`; rust: `sh -c`) |
| `@sleep N` | Pause for N seconds (fractions allowed) |
| `@input TEXT` | Simulate typed stdin input (visual only) |
| `@prompt TEXT` | Pause and wait for Enter (shows TEXT; defaults to "Press Enter to continue...") |
| `@clear` | Clear the screen |
| *(blank line)* | Outputs a blank line |
| *(anything else)* | Printed as-is |

## Install

**Prerequisites, up front:**

- **zsh** — required by the shell (reference) implementation. macOS ships
  it; on Linux install the `zsh` package.
- **Rust toolchain** (`cargo`) — required only to build the Rust
  implementation. Skip it if you only want the shell version.
- **asciinema** — optional; only used to play back `.cast` recordings in
  tabbing-on integration demos.
- **tabbing-on** — optional; enables the tab-title integration (next section).

There is no package-manager install, one-liner, or `curl | sh` installer —
none exists. Packaged installs (Homebrew, crates.io, and friends) are
*planned*, not available. The honest install is clone + make:

```sh
# from a checkout of this repository:
make install            # builds rust (if cargo present) and installs both

# what lands where:
#   ~/.local/bin/demo-runner     shell implementation (reference)
#   ~/.local/bin/demo-runner-rs  rust implementation
```

Make sure `~/.local/bin` is on your `PATH`. To install only the shell
implementation (no Rust toolchain needed):

```sh
make install-shell
```

## Usage

```sh
demo-runner                          # plays examples/tour.demo
demo-runner my-script.demo           # plays a custom script
demo-runner --fast                   # faster typing
demo-runner --slow                   # slower typing
demo-runner --speed medium           # fast | medium | slow
demo-runner --no-pause               # minimal pauses between commands (shell only)
demo-runner --reset-state            # delete the tabbing state dir first (see warning)
demo-runner --reset-state --dry-run  # print what would be deleted; delete nothing
```

Speed can also be set with the `DEMO_RUNNER_SPEED` environment variable
(`TABBING_DEMO_SPEED` is honoured for backwards compatibility) — shell
implementation only.

**`--reset-state` is destructive and irreversible.** It deletes
`${XDG_STATE_HOME:-~/.local/state}/tabbing` — every tab's history, todos
and asciinema recordings — before the demo starts (tabbing-on integration
active only), and prints the absolute path before deleting it. demo-runner
has **no backup mechanism**: deleted data cannot be recovered. Without the
flag, demo-runner never deletes anything. `--dry-run` modifies
`--reset-state` to print the target path and delete nothing; on its own it
has no effect (demo commands still execute).

Try the bundled examples:

```sh
demo-runner examples/tour.demo            # standalone tour of the format itself
demo-runner-rs examples/tour.demo         # same tour, rust implementation
demo-runner examples/tabbing-on-tour.demo # drives tab titles; needs tabbing-on
```

## Feature parity matrix

The shell implementation is the reference. Derived by reading both sources
(and cross-checked against tabbing-on's `docs/FEATURE-PARITY.md`, which
only tracks the pre-extraction state).

| Feature | `shell/` (zsh, reference) | `rust/` |
|---|---|---|
| `#` heading, bold + underline, instant | Yes | Yes |
| `##` description, dim, instant | Yes | Yes |
| `$` typed char-by-char, then executed | Yes (`eval`, current zsh) | Yes (`sh -c` subprocess) |
| Demo commands can use shell functions/aliases | Yes | No (plain `sh`, fresh process) |
| `@sleep N` (fractional) | Yes | Yes |
| `@input TEXT` | Yes | Yes |
| `@prompt [TEXT]` | Yes (reads `/dev/tty`) | Yes (reads stdin) |
| `@clear` | Yes (external `clear`) | Yes (inline ANSI) |
| `@speed fast\|medium\|slow` inline directive | No | Yes |
| Blank-line and verbatim-text passthrough | Yes | Yes |
| `--speed` / `--fast` / `--slow` flags | Yes | Yes |
| Speed via environment variable | Yes | No |
| `--no-pause` | Yes | No |
| `--reset-state` (opt-in tabbing state-dir wipe, prints path first) | Yes | No (rust never touches the tabbing state dir — nothing to reset) |
| `--dry-run` (with `--reset-state`: print, don't delete) | Yes | No (no `--reset-state` to dry-run) |
| Pause after each command | Yes (0.2–1.5 s) | No |
| Pause after headings | Yes | No |
| Default script when none given | Yes (`examples/tour.demo`) | No (path required) |
| Typing jitter (~1/3 of chars at 2x delay) | Yes | Yes |
| Abort when a demo command fails | Yes (`set -e`) | No (exit status ignored) |
| Extra blank line after each command | No | Yes |
| `--help` / `-h` | Yes | Yes |
| Final `Done!` banner | Yes | Yes |
| Optional tabbing-on integration | Yes (feature-detected) | No |
| `_tabbing_demo_create_sample_cast` / `_tabbing_demo_play_recording` helpers | Yes (with tabbing-on) | No (helpers absent) |
| asciinema playback inside demos | Yes (via helper) | No |

Small print: "fast" is 10 ms/char in shell vs 15 ms/char in rust; an
unknown `--speed` value silently falls back to medium in shell but exits 1
in rust.

## Optional tabbing-on integration

demo-runner has **no hard dependency** on
[tabbing-on](https://github.com/noizu/tabbing-on). A `.demo` file that uses
only headings, commands and `@`-directives runs correctly on a clean
machine with nothing else installed — that is a contract test
(`contract-tests/`), not a claim.

When tabbing-on **is** installed, demo-runner detects it and sources its
shell adapter, so demos can drive terminal tab titles and status:

- `tabbing-*` commands work inside `$` lines,
- `_tabbing_demo_create_sample_cast` creates a sample asciinema recording,
- `_tabbing_demo_play_recording` plays it back (needs asciinema),
- in-memory tab variables are reset before each run so demos start clean;
  the on-disk state dir is touched **only** when `--reset-state` is passed
  (integration mode only — see the warning under Usage). The default run
  deletes nothing.

Lookup order for the adapter: `$TABBING_ROOT/shell/tabbing.zsh`, then
`${XDG_DATA_HOME:-~/.local/share}/tabbing-on/shell/tabbing.zsh` (tabbing-on's
`make install` location), then a source checkout of tabbing-on sitting next
to this repository.

When tabbing-on is absent, the integration degrades gracefully and
silently: no error, no warning, and the two tabbing-specific helpers become
no-ops so tabbing-aware demo scripts still play. See
`examples/tabbing-on-tour.demo` for a demo that uses the integration.

## Contract tests

`contract-tests/` follows the fleet convention established by
direnv-config's `sdk/contract-tests`: one shared fixture corpus, asserted
identically against every implementation. The harness runs **both** the
shell and the Rust implementation over each `fixtures/*.demo` in a
scrubbed environment (no tabbing-on) and asserts identical normalized
output, per-fixture `.expect` expectations, and real command side effects.

This is also the shell implementation's first test coverage.

```sh
make test          # cargo unit tests + cross-implementation contract tests
```

## Development

```sh
make compile       # build the rust binary (release)
make test          # rust unit tests + contract tests
make install       # install both implementations to ~/.local/bin
make doctor        # check toolchain prerequisites and integration status
```

Repository layout:

```
shell/bin/demo-runner        reference implementation (zsh)
rust/                        standalone rust crate (std only, no deps)
examples/                    runnable example .demo files
contract-tests/              fixtures + cross-implementation harness
```

## License

MIT — see [LICENSE](LICENSE). Copyright (c) 2026 Keith Brings / Noizu Labs.
