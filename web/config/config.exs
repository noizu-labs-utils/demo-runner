import Config

config :demo_runner_web, DemoRunnerWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [formats: [html: DemoRunnerWeb.ErrorHTML], layout: false],
  pubsub_server: DemoRunnerWeb.PubSub,
  live_view: [signing_salt: "demoRunnerWeb"],
  secret_key_base: "DRw9xQ2eR7tY3uI6oP0aS5dF8gH1jK4lZ7xC2vB5nM8qW1eR4tY6uI9oP2aS5dGfJk",
  http: [ip: {127, 0, 0, 1}, port: 8170],
  server: true

config :phoenix, :json_library, Jason

config :logger, level: :info

# Runtime overrides (PORT / BIND_IP / PHX_HOST) — prod only, see runtime.exs.
import_config "runtime.exs"

# Test overrides (no HTTP listener).
if config_env() == :test, do: import_config("test.exs")
