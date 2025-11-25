defmodule AshAgentStudio.Hooks do
  @moduledoc """
  LiveView lifecycle hooks for Ash Agent Studio.

  Provides on_mount callbacks to extract configuration from the session
  and make it available to LiveViews and layouts.
  """

  import Phoenix.Component, only: [assign: 3]

  @doc """
  Assigns the base path from session to the socket.

  This hook extracts the `ash_agent_studio_base_path` from the session
  and assigns it as `base_path` on the socket, making it available
  to both LiveViews and the root layout.
  """
  def on_mount(:assign_base_path, _params, session, socket) do
    base_path = session["ash_agent_studio_base_path"] || "/"
    {:cont, assign(socket, :base_path, base_path)}
  end
end
