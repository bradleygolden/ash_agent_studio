defmodule AshAgentStudio.AssetController do
  @moduledoc false
  use Phoenix.Controller, formats: []

  @doc """
  Serves static assets from ash_agent_studio's priv/static/assets directory.
  """
  def show(conn, %{"asset" => asset}) do
    case :code.priv_dir(:ash_agent_studio) do
      {:error, :bad_name} ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(500, "ash_agent_studio priv directory not found")

      priv_dir ->
        path = Path.join([priv_dir, "static", "assets", asset])

        if File.exists?(path) do
          conn
          |> put_resp_content_type(MIME.from_path(path))
          |> send_file(200, path)
        else
          conn
          |> put_resp_content_type("text/plain")
          |> send_resp(404, "Asset not found: #{asset}")
        end
    end
  end
end
