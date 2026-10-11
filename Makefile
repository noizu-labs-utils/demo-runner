INSTALL_DIR := $(HOME)/.local/bin
CARGO        := cargo
RUST_DIR     := rust
RUST_BIN     := rust/target/release/demo-runner

.PHONY: help compile build test contract-test install install-shell uninstall check doctor clean

help:
	@echo "Targets:"
	@echo "  compile        Build the rust demo-runner binary (cargo build --release)"
	@echo "  build          Alias for compile"
	@echo "  test           Run rust unit tests + cross-implementation contract tests"
	@echo "  contract-test  Run the contract test harness only"
	@echo "  install        Build + install both implementations to $(INSTALL_DIR)"
	@echo "  install-shell  Install only the shell (reference) implementation"
	@echo "  uninstall      Remove installed binaries"
	@echo "  check          Verify installed binaries respond"
	@echo "  doctor         Diagnose toolchain prerequisites and tabbing-on integration"
	@echo "  clean          Remove build artifacts"

# --- Build ---

compile:
	@if command -v $(CARGO) >/dev/null 2>&1; then \
		echo "==> Building rust demo-runner (release)"; \
		cd $(RUST_DIR) && $(CARGO) build --release; \
	else \
		echo "==> Skipping compile: cargo not found (shell-only install available via 'make install-shell')"; \
	fi

build: compile

# --- Test ---

test:
	@echo "==> Running demo-runner tests"
	@if command -v $(CARGO) >/dev/null 2>&1; then \
		$(MAKE) compile; \
		$(CARGO) test --manifest-path $(RUST_DIR)/Cargo.toml; \
		$(MAKE) contract-test; \
	else \
		echo "==> Skipping rust tests: cargo not found"; \
		DR_SHELL_ONLY=1 $(MAKE) contract-test; \
	fi

contract-test:
	@sh contract-tests/run.sh

# --- Install ---

install: compile
	@$(MAKE) install-shell
	@if [ -x "$(RUST_BIN)" ]; then \
		mkdir -p $(INSTALL_DIR); \
		install -m 755 $(RUST_BIN) $(INSTALL_DIR)/demo-runner-rs; \
		echo "Installed: rust demo-runner → $(INSTALL_DIR)/demo-runner-rs"; \
	else \
		echo "==> Skipping rust install: $(RUST_BIN) not built (cargo missing?)"; \
	fi

install-shell:
	@mkdir -p $(INSTALL_DIR)
	@install -m 755 shell/bin/demo-runner $(INSTALL_DIR)/demo-runner
	@echo "Installed: shell demo-runner (reference) → $(INSTALL_DIR)/demo-runner"

uninstall:
	@rm -f $(INSTALL_DIR)/demo-runner $(INSTALL_DIR)/demo-runner-rs
	@echo "Removed demo-runner and demo-runner-rs from $(INSTALL_DIR)"

# --- Diagnostics ---

check:
	@echo "==> Checking installed binaries"
	@if command -v demo-runner >/dev/null 2>&1; then \
		demo-runner --help >/dev/null && echo "    demo-runner: ok"; \
	else \
		echo "    demo-runner: NOT on PATH (run 'make install-shell')"; exit 1; \
	fi
	@if command -v demo-runner-rs >/dev/null 2>&1; then \
		demo-runner-rs --help >/dev/null && echo "    demo-runner-rs: ok"; \
	else \
		echo "    demo-runner-rs: not installed (optional; needs cargo)"; \
	fi

doctor:
	@echo "==> demo-runner doctor"
	@if [ -x /bin/zsh ]; then echo "    zsh: $$(/bin/zsh --version | head -1)"; else echo "    zsh: MISSING (required by shell implementation)"; fi
	@if command -v $(CARGO) >/dev/null 2>&1; then echo "    cargo: $$(cargo --version)"; else echo "    cargo: not found (rust implementation not buildable)"; fi
	@if [ -x "$(RUST_BIN)" ]; then echo "    rust binary: built ($(RUST_BIN))"; else echo "    rust binary: not built (run 'make compile')"; fi
	@if command -v asciinema >/dev/null 2>&1; then echo "    asciinema: yes (recording playback available)"; else echo "    asciinema: not found (optional; recording playback only)"; fi
	@if [ -n "$${TABBING_ROOT:-}" ] && [ -f "$$TABBING_ROOT/shell/tabbing.zsh" ]; then \
		echo "    tabbing-on: found via TABBING_ROOT ($$TABBING_ROOT)"; \
	elif [ -f "$${XDG_DATA_HOME:-$$HOME/.local/share}/tabbing-on/shell/tabbing.zsh" ]; then \
		echo "    tabbing-on: found (installed adapter) — integration active"; \
	else \
		echo "    tabbing-on: not found — running standalone (integration optional)"; \
	fi

clean:
	@cd $(RUST_DIR) && $(CARGO) clean 2>/dev/null || true
	@echo "Cleaned rust build artifacts"
