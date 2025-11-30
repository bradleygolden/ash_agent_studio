defmodule AshAgentStudio.Dev.Agents.BamlChatAgent do
  @moduledoc """
  Chat agent using BAML with local Ollama (qwen3:1.7b).
  Used for testing the playground with BAML provider and streaming.
  """

  use Ash.Resource,
    domain: AshAgentStudio.Dev.Domain,
    extensions: [AshAgent.Resource, AshAgentStudio.Resource]

  resource do
    require_primary_key?(false)
  end

  agent do
    provider(:baml)
    client(:dev, function: :ChatAgent)
    output_schema(AshAgentStudio.BamlClients.Dev.Types.ChatReply)
    instruction("Prompt defined in BAML - this placeholder satisfies the DSL requirement")

    input_schema(Zoi.object(%{message: Zoi.string()}))
  end

  code_interface do
    define(:call, args: [:context])
    define(:stream, args: [:context])
  end
end
