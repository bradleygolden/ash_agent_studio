defmodule AshAgentStudio.Dev.Agents.ChatAgent do
  @moduledoc """
  A dev chat agent using AshAgent with Ollama.
  Used for testing the playground and observe features.
  """

  use Ash.Resource,
    domain: AshAgentStudio.Dev.Domain,
    extensions: [AshAgent.Resource, AshAgentStudio.Resource]

  import AshAgent.Sigils

  resource do
    require_primary_key?(false)
  end

  defmodule Reply do
    @moduledoc false
    use Ash.TypedStruct

    typed_struct do
      field(:content, :string, allow_nil?: false)
    end
  end

  # AshAgent configuration - uses local Ollama
  agent do
    client("openai:qwen3:1.7b",
      base_url: "http://localhost:11434/v1",
      api_key: "ollama",
      temperature: 0.7
    )

    output(Reply)

    prompt(~p"""
    You are a helpful assistant in the Ash Agent Studio playground.
    Reply with JSON matching the output format exactly.

    User message: {{ message }}

    {{ ctx.output_format }}
    """)

    input do
      argument(:message, :string, allow_nil?: false)
    end
  end

  # AshAgentStudio configuration for the playground UI
  agent_studio do
    label("Chat Agent")
    description("Chat agent using local Ollama (qwen3:1.7b)")
    group(:examples)

    input(:message, type: :string, doc: "Your message to the agent", allow_nil?: false)
  end

  # Code interface for convenient calling
  code_interface do
    define(:call, args: [:message])
    define(:stream, args: [:message])
  end
end
