defmodule AshAgentStudio.Dev.Endpoint do
  use Phoenix.Endpoint, otp_app: :ash_agent_studio

  @static_paths ~w(assets fonts images favicon.ico robots.txt)

  def static_paths, do: @static_paths

  @session_options [
    store: :cookie,
    key: "_ash_agent_studio_dev",
    signing_salt: "dev_signing_salt",
    same_site: "Lax"
  ]

  socket("/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]])

  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)
    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)
  end

  plug(Plug.Static,
    at: "/",
    from: :ash_agent_studio,
    gzip: false,
    only: @static_paths
  )

  plug(Plug.RequestId)
  plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint])

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)
  plug(Plug.Session, @session_options)

  plug(AshAgentStudio.Dev.Router)
end
