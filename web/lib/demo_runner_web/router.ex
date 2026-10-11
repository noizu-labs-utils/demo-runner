defmodule DemoRunnerWeb.Router do
  use Phoenix.Router

  get "/healthz", DemoRunnerWeb.Controllers.Health, :show
end
