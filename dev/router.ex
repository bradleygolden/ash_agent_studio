defmodule AshAgentStudio.Dev.Router do
  use Phoenix.Router
  use AshAgentStudio.Router

  import Phoenix.LiveView.Router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  scope "/" do
    pipe_through(:browser)
    ash_agent_studio("/")
  end
end
