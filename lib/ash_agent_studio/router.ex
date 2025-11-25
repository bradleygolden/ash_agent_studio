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

  Note: Asset routes are registered at the module level (outside any scopes/pipelines) to avoid
  authentication requirements. This follows the same pattern as Phoenix LiveDashboard.
  """

  defmacro __using__(_opts) do
    quote do
      import AshAgentStudio.Router
      @before_compile AshAgentStudio.Router
      Module.register_attribute(__MODULE__, :ash_agent_studio_prefix, accumulate: false)
    end
  end

  defmacro __before_compile__(env) do
    prefix = Module.get_attribute(env.module, :ash_agent_studio_prefix)

    if prefix do
      quote do
        # Register asset route at module level (outside any scopes/pipelines)
        # This bypasses authentication pipelines, following LiveDashboard's pattern
        scope unquote(prefix), alias: false do
          get("/assets/:asset", AshAgentStudio.AssetController, :show)
        end
      end
    end
  end

  defmacro ash_agent_studio(path, opts \\ []) do
    validated_path = validate_path!(path)

    quote bind_quoted: [path: validated_path, opts: opts], location: :keep do
      scope_opts = [as: Keyword.get(opts, :as, :ash_agent_studio), alias: false]

      # Compute the full scoped path at compile time (includes parent scopes)
      full_path = Phoenix.Router.scoped_path(__MODULE__, path)

      # Store the full path for asset route registration in @before_compile
      @ash_agent_studio_prefix full_path

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
