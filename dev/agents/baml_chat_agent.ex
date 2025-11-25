defmodule AshAgentStudio.Dev.Agents.BamlChatAgent do
  @moduledoc """
  A dev chat agent using AshAgent with BAML provider and Ollama.
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
    output(AshAgentStudio.BamlClients.Dev.Types.ChatReply)
    prompt("Prompt defined in BAML - this placeholder satisfies the DSL requirement")

    input do
      argument(:message, :string, allow_nil?: false)
    end
  end

  agent_studio do
    label("BAML Chat Agent")
    description("Chat agent using BAML with local Ollama (qwen3:1.7b)")
    group(:examples)

    input(:message, type: :string, doc: "Your message to the agent", allow_nil?: false)
  end

  code_interface do
    define(:call, args: [:message])
    define(:stream, args: [:message])
  end
end
