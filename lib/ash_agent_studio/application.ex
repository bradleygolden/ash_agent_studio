defmodule AshAgentStudio.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        {Phoenix.PubSub, name: AshAgentStudio.PubSub},
        {AshAgentStudio.Observe.Store, []},
        {AshAgentStudio.Observe.Telemetry, []},
        {AshAgentStudio.Registry, []}
      ] ++ dev_children()

    result =
      Supervisor.start_link(children, strategy: :one_for_one, name: AshAgentStudio.Supervisor)

    load_dev_agents()
    AshAgentStudio.Registry.discover_agents()

    result
  end

  # In dev mode, start the dev endpoint for the playground
  if Mix.env() == :dev do
    defp dev_children do
      [{AshAgentStudio.Dev.Endpoint, []}]
    end

    defp load_dev_agents do
      Code.ensure_loaded!(AshAgentStudio.Dev.Agents.EchoAgent)
      Code.ensure_loaded!(AshAgentStudio.Dev.Agents.ChatAgent)
      Code.ensure_loaded!(AshAgentStudio.Dev.Agents.BamlChatAgent)
    end
  else
    defp dev_children do
      []
    end

    defp load_dev_agents, do: :ok
  end
end
