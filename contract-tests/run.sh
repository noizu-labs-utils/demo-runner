#!/bin/sh
# contract-tests/run.sh — cross-implementation contract harness for demo-runner.
#
# Shape follows the fleet convention of direnv-config's sdk/contract-tests:
# one shared fixture corpus, asserted identically against every implementation.
#
# For every fixtures/*.demo this harness asserts:
#   1. both implementations exit 0,
#   2. the normalized output of the shell reference equals the normalized
#      output of the rust implementation,
#   3. the per-fixture <name>.expect assertions hold for BOTH implementations.
#
# Expectation file format (one per line):
#   contains:<substring>   fixed-string substring that must appear in output
#   file:<path>=<content>  file created in the sandbox cwd with exact content
#   blank lines / # comments are ignored
#
# Normalization strips ANSI CSI sequences, trailing whitespace and ALL blank
# lines. Blank lines are excluded because the implementations legitimately
# differ there today: the rust impl prints one extra blank line after each
# executed command (documented in the README parity matrix).
#
# Every run executes in a scrubbed environment (env -i, sandbox $HOME,
# minimal PATH) with no TABBING_ROOT — tabbing-on is deliberately absent,
# so the whole suite continuously regression-tests the standalone/decoupled
# mode of the shell reference implementation.
#
# Environment:
#   DR_RUST_BIN=path   use a specific rust binary
#   DR_SHELL_ONLY=1    skip the rust side (shell expectations only)
#   ZSH_BIN=path       zsh interpreter (default /bin/zsh)

set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SHELL_IMPL="$ROOT/shell/bin/demo-runner"
FIXTURES="$ROOT/contract-tests/fixtures"
ZSH_BIN="${ZSH_BIN:-/bin/zsh}"
SHELL_ONLY="${DR_SHELL_ONLY:-0}"

RUST_BIN="${DR_RUST_BIN:-}"
if [ -z "$RUST_BIN" ]; then
  for cand in "$ROOT/rust/target/release/demo-runner" "$ROOT/rust/target/debug/demo-runner"; do
    if [ -x "$cand" ]; then RUST_BIN="$cand"; break; fi
  done
fi

ESC="$(printf '\033')"

normalize() {
  sed -e "s/${ESC}\[[0-9;]*[A-Za-z]//g" -e 's/[[:space:]]*$//' | grep -v '^[[:space:]]*$'
}

run_shell() { # $1 sandbox, $2 fixture
  mkdir -p "$1/home"
  (
    cd "$1" || exit 97
    env -i PATH="/usr/bin:/bin" HOME="$1/home" TERM=xterm \
      "$ZSH_BIN" "$SHELL_IMPL" --speed fast --no-pause "$2" > "$1/out" 2>&1
  )
  echo "$?" > "$1/rc"
  normalize < "$1/out" > "$1/out.norm"
}

run_rust() { # $1 sandbox, $2 fixture
  mkdir -p "$1/home"
  (
    cd "$1" || exit 97
    env -i PATH="/usr/bin:/bin" HOME="$1/home" TERM=xterm \
      "$RUST_BIN" --speed fast "$2" > "$1/out" 2>&1
  )
  echo "$?" > "$1/rc"
  normalize < "$1/out" > "$1/out.norm"
}

check_expect() { # $1 label, $2 out file base (.norm appended), $3 sandbox cwd, $4 expect file
  [ -f "$4" ] || return 0
  while IFS= read -r line; do
    case "$line" in
      '' | '#'*) continue ;;
      contains:*)
        want="${line#contains:}"
        grep -Fq -- "$want" "$2.norm" || printf '   %s: output missing %s\n' "$1" "$want"
        ;;
      file:*)
        rest="${line#file:}"
        fpath="${rest%%=*}"
        want="${rest#*=}"
        ffile="$3/$fpath"
        if [ ! -f "$ffile" ]; then
          printf '   %s: file not created: %s\n' "$1" "$fpath"
        elif [ ! "$(cat "$ffile")" = "$want" ]; then
          printf '   %s: %s content mismatch (want: %s)\n' "$1" "$fpath" "$want"
        fi
        ;;
      *)
        printf '   %s: bad .expect line: %s\n' "$1" "$line"
        ;;
    esac
  done < "$4"
}

if [ ! -f "$SHELL_IMPL" ]; then
  echo "contract-tests: shell implementation not found: $SHELL_IMPL" >&2
  exit 1
fi
if [ ! -x "$ZSH_BIN" ]; then
  echo "contract-tests: zsh not found at $ZSH_BIN (set ZSH_BIN)" >&2
  exit 1
fi
if [ "$SHELL_ONLY" != "1" ] && [ -z "$RUST_BIN" ]; then
  echo "contract-tests: rust binary not built (run 'make compile') or set DR_SHELL_ONLY=1" >&2
  exit 1
fi

WORK="$(mktemp -d "${TMPDIR:-/tmp}/dr-contract.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT INT TERM

TOTAL=0
FAILED=0
RUST_RUN=0

echo "==> demo-runner contract tests"
echo "    shell: $SHELL_IMPL"
if [ "$SHELL_ONLY" = "1" ]; then
  echo "    rust:  SKIPPED (DR_SHELL_ONLY=1)"
else
  echo "    rust:  $RUST_BIN"
fi
echo "    env:   scrubbed (env -i) — tabbing-on absent, standalone mode exercised"

for fixture in "$FIXTURES"/*.demo; do
  [ -f "$fixture" ] || continue
  TOTAL=$((TOTAL + 1))
  name="$(basename "$fixture" .demo)"
  errs=""

  sb="$WORK/$name/shell"
  mkdir -p "$sb"
  run_shell "$sb" "$fixture"
  rc="$(cat "$sb/rc")"
  [ "$rc" = "0" ] || errs="${errs}   shell: exit $rc\n"
  if grep -q 'command not found' "$sb/out" 2>/dev/null; then
    errs="${errs}   shell: 'command not found' in output\n"
  fi
  errs="$errs$(check_expect shell "$sb/out" "$sb" "$FIXTURES/$name.expect")"

  if [ "$SHELL_ONLY" = "1" ]; then
    cross_note="(rust skipped)"
  else
    RUST_RUN=$((RUST_RUN + 1))
    rb="$WORK/$name/rust"
    mkdir -p "$rb"
    run_rust "$rb" "$fixture"
    rc="$(cat "$rb/rc")"
    [ "$rc" = "0" ] || errs="${errs}   rust: exit $rc\n"
    errs="$errs$(check_expect rust "$rb/out" "$rb" "$FIXTURES/$name.expect")"

    cross_note="(shell == rust)"
    normalize < "$sb/out" > "$WORK/$name/shell.norm"
    normalize < "$rb/out" > "$WORK/$name/rust.norm"
    if ! diff -u "$WORK/$name/shell.norm" "$WORK/$name/rust.norm" > "$WORK/$name/diff" 2>&1; then
      errs="${errs}   cross-impl: normalized output differs\n"
      cross_note="(cross-impl DIFF)"
      sed 's/^/     /' "$WORK/$name/diff"
    fi
  fi

  if [ -n "$errs" ]; then
    FAILED=$((FAILED + 1))
    printf 'FAIL  %s %s\n%b' "$name" "$cross_note" "$errs"
  else
    printf 'ok    %s %s\n' "$name" "$cross_note"
  fi
done

echo ""
echo "==> contract tests: $((TOTAL - FAILED))/$TOTAL fixtures passed, $RUST_RUN cross-impl comparisons"
[ "$FAILED" -eq 0 ] || exit 1
exit 0
