defmodule AshAgentStudio.Router do
  @moduledoc """
  Routing helpers for embedding Ash Agent Studio screens, modeled after `Phoenix.LiveDashboard.Router`.

  Import (or `use`) the helper from inside your router, wrap it in whatever scopes/pipelines you need,
  and pass the mount path as the first argument:

      defmodule MyAppWeb.Router do
        use MyAppWeb, :router
        use AshAgentStudio.Router

        scope "/" do
          pipe_through [:browser, :require_user]
          ash_agent_studio "/studio"
        end
      end
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

      scope path, scope_opts do
        live_session :ash_agent_studio,
          session: %{"ash_agent_studio_base_path" => path},
          root_layout: {AshAgentStudio.Layouts.Root, :root} do
          live("/", AshAgentStudio.OverviewLive, :home)
          live("/runs/:id", AshAgentStudio.RunLive, :run)
          live("/playground", AshAgentStudio.PlaygroundLive, :playground)
          get("/assets/:asset", AshAgentStudio.AssetController, :show)
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
