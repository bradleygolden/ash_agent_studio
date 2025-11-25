defmodule AshAgentStudio.Registry do
  @moduledoc """
  Registry for agents registered with Ash Agent Studio.

  Agents that use the `AshAgentStudio.Resource` extension are automatically
  registered here at compile time.
  """

  use GenServer

  @table_name :ash_agent_studio_registry

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Register an agent module with its studio configuration.
  """
  def register(module, config) do
    GenServer.call(__MODULE__, {:register, module, config})
  end

  @doc """
  List all registered agents.

  Returns a list of `{module, config}` tuples.
  """
  def list_agents do
    :ets.tab2list(@table_name)
  rescue
    ArgumentError -> []
  end

  @doc """
  Get the studio configuration for a specific agent.
  """
  def get_config(module) do
    case :ets.lookup(@table_name, module) do
      [{^module, config}] -> {:ok, config}
      [] -> :error
    end
  rescue
    ArgumentError -> :error
  end

  @doc """
  Check if an agent is registered.
  """
  def registered?(module) do
    :ets.member(@table_name, module)
  rescue
    ArgumentError -> false
  end

  # GenServer callbacks

  @impl true
  def init(_opts) do
    table = :ets.new(@table_name, [:named_table, :public, :set])
    {:ok, %{table: table}}
  end

  @impl true
  def handle_call({:register, module, config}, _from, state) do
    :ets.insert(@table_name, {module, config})
    {:reply, :ok, state}
  end
end
