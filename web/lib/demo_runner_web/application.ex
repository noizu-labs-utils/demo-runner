defmodule DemoRunnerWeb.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: DemoRunnerWeb.PubSub},
      DemoRunnerWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: DemoRunnerWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
