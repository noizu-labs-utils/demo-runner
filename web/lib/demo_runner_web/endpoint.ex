defmodule DemoRunnerWeb.Endpoint do
  @moduledoc """
  〚📦:1f2a0b7c-a6f4-53f5-a880-2ec651bd43b4〛 DemoRunnerWeb.Endpoint :: Plug pipeline — static assets, cookie session, Hologram router before Phoenix.
  """

  use Phoenix.Endpoint, otp_app: :demo_runner_web

  # Hologram's client runtime is served from the "hologram" path;
  # our own assets from "assets".
  plug Plug.Static,
    at: "/",
    from: :demo_runner_web,
    only: ["assets", "hologram"],
    gzip: false

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Jason

  plug Plug.Session,
    store: :cookie,
    key: "_demo_runner_web_key",
    signing_salt: "demoRunnerWeb"

  # Hologram's router must run BEFORE the Phoenix router.
  plug Hologram.Router
  plug DemoRunnerWeb.Router
end
