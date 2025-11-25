defmodule AshAgentStudio.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: AshAgentStudio.PubSub},
      {AshAgentStudio.Observe.Store, []},
      {AshAgentStudio.Observe.Telemetry, []},
      {AshAgentStudio.Registry, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: AshAgentStudio.Supervisor)
  end
end
