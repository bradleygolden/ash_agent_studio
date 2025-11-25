defmodule AshAgentStudio.Dev.Agents.EchoAgent do
  @moduledoc """
  A simple example agent that echoes back the input message.
  Used for testing the playground.
  """

  use Ash.Resource,
    domain: nil,
    extensions: [AshAgentStudio.Resource]

  agent_studio do
    label("Echo Agent")
    description("A simple agent that echoes back your message")
    group(:examples)

    input(:message, type: :string, doc: "The message to echo back", allow_nil?: false)
  end

  def call(args) do
    message = Keyword.get(args, :message, "Hello!")

    {:ok,
     %{
       response: "Echo: #{message}",
       timestamp: DateTime.utc_now()
     }}
  end
end
