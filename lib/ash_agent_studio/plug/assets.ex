defmodule AshAgentStudio.Plug.Assets do
  @moduledoc """
  A Plug that serves Ash Agent Studio static assets.

  Add this plug to your endpoint BEFORE the router:

      # In your endpoint.ex
      plug AshAgentStudio.Plug.Assets

  This serves assets at any path matching `*/assets/app.css` or `*/assets/app.js`
  where the request is for ash_agent_studio assets.
  """

  @behaviour Plug

  @impl true
  def init(opts), do: opts

  @impl true
  def call(%{path_info: path_info} = conn, _opts) do
    case List.last(path_info, nil) do
      asset when asset in ["app.css", "app.js"] ->
        # Check if this looks like an ash_agent_studio asset path
        if "assets" in path_info do
          serve_asset(conn, asset)
        else
          conn
        end

      _ ->
        conn
    end
  end

  defp serve_asset(conn, asset) do
    case :code.priv_dir(:ash_agent_studio) do
      {:error, :bad_name} ->
        conn

      priv_dir ->
        path = Path.join([priv_dir, "static", "assets", asset])

        if File.exists?(path) do
          conn
          |> Plug.Conn.put_resp_content_type(MIME.from_path(path))
          |> Plug.Conn.send_file(200, path)
          |> Plug.Conn.halt()
        else
          conn
        end
    end
  end
end
