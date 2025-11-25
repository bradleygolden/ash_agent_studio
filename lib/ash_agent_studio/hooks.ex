defmodule AshAgentStudio.Hooks do
  @moduledoc """
  LiveView lifecycle hooks for Ash Agent Studio.

  Provides on_mount callbacks to extract configuration from the session
  and make it available to LiveViews and layouts.
  """

  import Phoenix.Component, only: [assign: 3]

  @doc """
  Assigns the base path from session to the socket.

  The base path is computed at compile time in the router macro using
  `Phoenix.Router.scoped_path/2`, which correctly handles nested scopes.
  """
  def on_mount(:assign_base_path, _params, session, socket) do
    base_path = session["ash_agent_studio_base_path"] || "/"
    {:cont, assign(socket, :base_path, base_path)}
  end
end
