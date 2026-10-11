import Config

# Test overrides — no HTTP listener; requests go through Phoenix.ConnTest.
config :demo_runner_web, DemoRunnerWeb.Endpoint,
  server: false,
  http: [ip: {127, 0, 0, 1}, port: 8171]
