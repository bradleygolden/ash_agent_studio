defmodule AshAgentStudio.Dev.Domain do
  @moduledoc """
  Domain for dev agents used in the Ash Agent Studio playground.
  """
  use Ash.Domain, validate_config_inclusion?: false

  resources do
    resource(AshAgentStudio.Dev.Agents.ChatAgent)
    resource(AshAgentStudio.Dev.Agents.BamlChatAgent)
  end
end
