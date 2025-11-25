defmodule AshAgentStudio.RouterTest do
  use ExUnit.Case, async: true

  defmodule TestRouter do
    use Phoenix.Router
    import Phoenix.LiveView.Router
    use AshAgentStudio.Router

    pipeline :browser do
      plug(:accepts, ["html"])
    end

    scope "/" do
      pipe_through(:browser)
      ash_agent_studio("/ash-agent-ui")
    end
  end

  test "defines live routes at the given path" do
    routes = Phoenix.Router.routes(TestRouter)

    assert Enum.any?(routes, fn route ->
             route.plug == Phoenix.LiveView.Plug and route.path == "/ash-agent-ui"
           end)

    assert Enum.any?(routes, fn route ->
             route.plug == Phoenix.LiveView.Plug and route.path == "/ash-agent-ui/runs/:id"
           end)
  end

  test "rejects non-string paths" do
    message =
      assert_raise ArgumentError, fn ->
        defmodule BrokenRouter do
          use Phoenix.Router
          import Phoenix.LiveView.Router
          use AshAgentStudio.Router

          scope "/" do
            ash_agent_studio(123)
          end
        end
      end

    assert Exception.message(message) =~ "expects a string path"
  end
end
