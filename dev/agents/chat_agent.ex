defmodule AshAgentStudio.Dev.Agents.ChatAgent do
  @moduledoc """
  Chat agent using local Ollama (qwen3:1.7b).
  Used for testing the playground and observe features.
  """

  use Ash.Resource,
    domain: AshAgentStudio.Dev.Domain,
    extensions: [AshAgent.Resource, AshAgentStudio.Resource]

  import AshAgent.Sigils

  resource do
    require_primary_key?(false)
  end

  agent do
    client("openai:qwen3:1.7b",
      base_url: "http://localhost:11434/v1",
      api_key: "ollama",
      temperature: 0.7
    )

    input_schema(Zoi.object(%{message: Zoi.string()}, coerce: true))

    output_schema(Zoi.object(%{content: Zoi.string()}, coerce: true))

    prompt(~p"""
    You are a helpful assistant in the Ash Agent Studio playground.
    Reply with JSON matching the output format exactly.

    User message: {{ message }}

    {{ ctx.output_format }}
    """)
  end
end
