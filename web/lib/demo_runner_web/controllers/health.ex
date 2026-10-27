defmodule DemoRunnerWeb.Controllers.Health do
  @moduledoc """
  〚📦:13cc693d-24f8-5ab8-9f4d-2aae41b6b750〛 DemoRunnerWeb.Controllers.Health :: Liveness/readiness 200 "ok" for k8s probes.

  Trivial liveness/readiness endpoint for k8s probes.
  """

  use Phoenix.Controller, formats: [html: DemoRunnerWeb.ErrorHTML]

  def show(conn, _params), do: send_resp(conn, 200, "ok")
end
