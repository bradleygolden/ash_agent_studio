defmodule AshAgentStudio.Dev.Agents.EchoAgent do
  @moduledoc """
  A simple example agent that echoes back the input message.
  Used for testing the playground without AshAgent.
  """

  use Ash.Resource,
    domain: nil,
    extensions: [AshAgentStudio.Resource]

  def call(args) do
    message = Keyword.get(args, :message, "Hello!")

    {:ok,
     %{
       response: "Echo: #{message}",
       timestamp: DateTime.utc_now()
     }}
  end
end
