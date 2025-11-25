defmodule AshAgentStudio.Dev.Application do
  @moduledoc """
  Dev application module.

  Note: The main AshAgentStudio.Application handles starting the dev endpoint
  and loading dev agents when MIX_ENV=dev. This module is kept for backwards
  compatibility but is no longer needed for normal dev server startup.

  To start the dev server, simply run: `mix dev`
  """

  def start do
    IO.puts("""
    Note: Dev server is automatically started by the main application.
    Use `mix dev` or `iex -S mix` to start the server.
    """)

    :ok
  end
end
