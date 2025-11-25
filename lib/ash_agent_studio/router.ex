defmodule AshAgentStudio.Router do
  @moduledoc """
  Routing helpers for embedding Ash Agent Studio screens, modeled after `Phoenix.LiveDashboard.Router`.

  ## Setup

  1. Add the assets plug to your endpoint (before the router):

      # In your endpoint.ex
      plug AshAgentStudio.Plug.Assets

  2. Import and use the router helper:

      defmodule MyAppWeb.Router do
        use MyAppWeb, :router
        use AshAgentStudio.Router

        scope "/" do
          pipe_through [:browser, :require_user]
          ash_agent_studio "/studio"
        end
      end

  The assets plug serves static files at the endpoint level, bypassing authentication
  pipelines. This ensures assets load regardless of how you configure your router.
  """

  defmacro __using__(_opts) do
    quote do
      import AshAgentStudio.Router
    end
  end

  defmacro ash_agent_studio(path, opts \\ []) do
    validated_path = validate_path!(path)

    quote bind_quoted: [path: validated_path, opts: opts], location: :keep do
      scope_opts = [as: Keyword.get(opts, :as, :ash_agent_studio), alias: false]

      # Compute the full scoped path at compile time (includes parent scopes)
      full_path = Phoenix.Router.scoped_path(__MODULE__, path)

      scope path, scope_opts do
        live_session :ash_agent_studio,
          session: %{"ash_agent_studio_base_path" => full_path},
          on_mount: {AshAgentStudio.Hooks, :assign_base_path},
          root_layout: {AshAgentStudio.Layouts.Root, :root} do
          live("/", AshAgentStudio.OverviewLive, :home)
          live("/runs/:id", AshAgentStudio.RunLive, :run)
          live("/playground", AshAgentStudio.PlaygroundLive, :playground)
        end
      end
    end
  end

  defp validate_path!(<<"/"::binary, _::binary>> = path), do: path

  defp validate_path!(path) when is_binary(path) do
    raise ArgumentError,
          "ash_agent_studio/2 expects paths to start with \"/\", got: #{inspect(path)}"
  end

  defp validate_path!(path) do
    raise ArgumentError, "ash_agent_studio/2 expects a string path, got: #{inspect(path)}"
  end
end
