defmodule DemoRunnerWeb.RequestTest do
  use ExUnit.Case, async: false
  import Phoenix.ConnTest

  @endpoint DemoRunnerWeb.Endpoint

  test "GET /healthz returns ok for k8s probes" do
    conn = get(build_conn(), "/healthz")
    assert conn.status == 200
    assert conn.resp_body == "ok"
  end

  test "GET / renders the landing page with the hero headline" do
    conn = get(build_conn(), "/")
    assert conn.status == 200
    assert conn.resp_body =~ "Write the demo once. Replay it live."
  end

  test "GET / includes SEO head tags" do
    conn = get(build_conn(), "/")
    body = conn.resp_body

    assert body =~ "<title>demo-runner — Write the demo once. Replay it live.</title>"
    assert body =~ ~r/name="description" content="demo-runner is a typewriter-style/
    assert body =~ "og:title"
  end

  test "GET / includes benefits, format, parity, safety, neighbours, and FAQ copy" do
    conn = get(build_conn(), "/")
    body = conn.resp_body

    assert body =~ "Demos as data"
    assert body =~ "Real execution"
    assert body =~ "Safe by default"
    assert body =~ "The .demo format"
    assert body =~ "Pause and wait for Enter"
    assert body =~ "Two implementations, one reference"
    assert body =~ "Nothing is deleted by default"
    assert body =~ "demo-runner and its neighbours"
    assert body =~ "Does it really execute the commands?"
    assert body =~ "the license?"
    assert body =~ "make doctor"
    assert body =~ "Install from source"
  end

  test "GET / presents the parity matrix honestly" do
    conn = get(build_conn(), "/")
    body = conn.resp_body

    # The lopsided verdict is stated, not implied equivalence.
    assert body =~ "the shell reference carries 12 capabilities the Rust port lacks"
    assert body =~ "the Rust port adds exactly one the shell lacks"
    assert body =~ "@speed fast|medium|slow inline directive"
    assert body =~ "rust never touches the tabbing state dir"
    assert body =~ "Reference-only"
  end

  test "GET / frames --reset-state as opt-in, never a default wipe" do
    conn = get(build_conn(), "/")
    body = conn.resp_body

    assert body =~ "never deletes anything unless you pass"
    assert body =~ "opt-in"
    assert body =~ "prints the absolute path"
    assert body =~ "--reset-state --dry-run"
    assert body =~ "a plain run must never delete user state"
  end

  test "GET / keeps the install section honest" do
    conn = get(build_conn(), "/")
    body = conn.resp_body

    # Prerequisites stated up front; no package-manager / one-liner promises.
    assert body =~ "prerequisites: zsh for the shell reference implementation"
    assert body =~ "not on Homebrew, crates.io, or npm"
    assert body =~ "Packaged installs are planned"
    assert body =~ "git clone https://github.com/noizu/demo-runner"
    # The disclaimer itself names curl | sh to deny it — assert the denial,
    # and refute actual installer invocations.
    assert body =~ "no one-liner and no"
    assert body =~ "curl | sh"
    refute body =~ ~r/brew install/
    refute body =~ ~r/cargo install/
  end

  test "GET / uses the real repo and provenance links, correct domain spelling" do
    conn = get(build_conn(), "/")
    body = conn.resp_body

    assert body =~ "https://github.com/noizu/demo-runner"
    assert body =~ "https://github.com/noizu/tabbing-on"
    assert body =~ "demo-runner.therobotlives.com"
    # The double-r misspelling has caused real bugs; guard the rendered copy.
    refute body =~ "therrobotlives"
    refute body =~ "therobotllives"
  end

  test "GET / contains no internal hostnames or personal paths" do
    conn = get(build_conn(), "/")
    body = conn.resp_body

    refute body =~ "derobot.is"
    refute body =~ "codefre.sh"
    refute body =~ "gotta.cc"
    refute body =~ "aifighter.com"
    refute body =~ "ops.noizu"
    refute body =~ "/Users/"
  end

  test "GET / includes footer attribution" do
    conn = get(build_conn(), "/")
    body = conn.resp_body

    assert body =~ "a noizu.com project"
    assert body =~ "https://github.com/noizu/demo-runner"
    assert body =~ "This site is Elixir Hologram."
  end

  test "static assets are served" do
    conn = get(build_conn(), "/assets/css/site.css")
    assert conn.status == 200
  end

end
