defmodule DemoRunnerWeb.Router do
  @moduledoc """
  〚📦:ccd1f850-1ec1-5711-8019-b868925e833a〛 DemoRunnerWeb.Router :: Phoenix routes; /healthz only — pages ride the Hologram router.
  """

  use Phoenix.Router

  get "/healthz", DemoRunnerWeb.Controllers.Health, :show
end
