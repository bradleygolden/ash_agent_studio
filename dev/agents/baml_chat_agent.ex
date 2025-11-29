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

    input_schema(Zoi.object(%{message: Zoi.string()}, coerce: true))

    output_schema(Zoi.object(%{message: Zoi.string()}, coerce: true))
  end
end
