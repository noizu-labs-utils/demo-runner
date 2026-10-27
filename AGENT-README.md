# AGENT-README

> Orientation for AI coding agents working in this repo. Human docs: README.md.

## Type

cli-tool+rust

## Purpose

Typewriter-style scripted terminal demo player: reads a `.demo` script and plays it back like a human operator — headings appear instantly, `$ command` lines are typed out character-by-character then actually executed; `@`-directives add pauses, simulated input, prompts, and screen clears.

## Stack

Dual implementation: zsh reference (`shell/`, canonical + complete) and a std-only Rust binary (`rust/`, no external crates); Makefile installs both.

## Dev mode

```bash
make install             # builds rust (if cargo present); installs demo-runner + demo-runner-rs to ~/.local/bin
make install-shell       # shell implementation only, no Rust toolchain needed
demo-runner examples/tour.demo
```

## Ports / URLs

- none (library/CLI)

## Tests

```bash
make test                # cargo test when cargo is present
```

## Gotchas

- The Rust implementation is not at feature parity with the shell reference — check the matrix in README.md before porting features.
- zsh is required by the reference implementation (macOS ships it; Linux needs the zsh package).
- No package-manager install exists (Homebrew/crates.io planned, not available) — clone + make only.
