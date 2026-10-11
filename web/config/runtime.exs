import Config

# Runtime overrides for `mix release` containers. Only evaluated by the
# release's config provider — dev/test keep the settings in config.exs.
if config_env() == :prod do
  # Tolerate malformed BIND_IP/PORT instead of crashing the release at
  # boot with a badarg from String.to_integer/1: fall back to sane
  # defaults so misconfiguration stays survivable.
  ip =
    try do
      System.get_env("BIND_IP", "0.0.0.0")
      |> String.split(".")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    rescue
      ArgumentError -> {0, 0, 0, 0}
    end

  port =
    case System.get_env("PORT", "8170") |> Integer.parse() do
      {p, ""} when p > 0 and p <= 65535 -> p
      _ -> 8170
    end

  config :demo_runner_web, DemoRunnerWeb.Endpoint,
    url: [host: System.get_env("PHX_HOST", "demo-runner.therobotlives.com")],
    http: [ip: ip, port: port],
    server: true

  # Public repo: the config.exs secret_key_base is a committed dev default
  # (it signs cookies for a sessionless landing page — low impact). Let
  # deployments rotate it via env without a code change, mirroring the
  # Phoenix release generator pattern.
  if secret = System.get_env("SECRET_KEY_BASE") do
    config :demo_runner_web, DemoRunnerWeb.Endpoint, secret_key_base: secret
  end
end
