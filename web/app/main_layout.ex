defmodule DemoRunnerWeb.MainLayout do
  @moduledoc """
  Root layout for the demo-runner landing page — head (SEO + OG), sticky header
  nav, footer. Dark-first typographic dev-tool theme; tokens in
  /assets/css/site.css. Copy source of truth: web/COPY.md.
  """

  use Hologram.Component

  def template do
    ~HOLO"""
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>demo-runner — Write the demo once. Replay it live.</title>
        <meta
          name="description"
          content="demo-runner is a typewriter-style scripted terminal demo player: a plain-text .demo script becomes a live playback — headings appear instantly, $ commands are typed character-by-character then actually executed, with @sleep/@input/@prompt/@clear directives and speed control. zsh reference implementation plus a Rust port, contract-tested, MIT licensed."
        />
        <meta property="og:type" content="website" />
        <meta property="og:title" content="demo-runner — Write the demo once. Replay it live." />
        <meta
          property="og:description"
          content="A typewriter-style scripted terminal demo player. Write the demo once as a .demo text file; replay it live at any speed, with commands really executed. Never deletes anything by default."
        />
        <meta property="og:url" content="https://demo-runner.therobotlives.com/" />
        <meta name="twitter:card" content="summary" />
        <link rel="icon" href="/assets/favicon.svg" type="image/svg+xml" />
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
        <link
          href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;family=JetBrains+Mono:wght@400;500;700&amp;display=swap"
          rel="stylesheet"
        />
        <link rel="stylesheet" href="/assets/css/site.css" />
        <Hologram.UI.Runtime />
      </head>
      <body>
        <a class="skip-link" href="#main">Skip to content</a>

        <header class="site-header">
          <div class="container header-inner">
            <a class="brand" href="#top" aria-label="demo-runner home">
              <span class="brand-mark" aria-hidden="true">$</span>
              <span class="brand-name">demo-runner</span>
            </a>
            <nav class="site-nav" aria-label="Primary">
              <a href="#format">Format</a>
              <a href="#parity">Parity</a>
              <a href="#safety">Safety</a>
              <a href="#faq">FAQ</a>
              <a class="btn btn-primary btn-sm" href="#install">Install</a>
            </nav>
          </div>
        </header>

        <main id="main">
          <slot />
        </main>

        <footer class="site-footer">
          <div class="container footer-inner">
            <p class="footer-brand">demo-runner — a noizu.com project</p>
            <p class="footer-line">
              <a href="https://github.com/noizu/demo-runner">GitHub</a> ·
              <a href="https://github.com/noizu/demo-runner/blob/main/LICENSE">MIT licensed</a> ·
              This site is Elixir Hologram. · © 2026
            </p>
          </div>
        </footer>
      </body>
    </html>
    """
  end
end
