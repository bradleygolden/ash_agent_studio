defmodule AshAgentStudio.OverviewLiveTest do
  use ExUnit.Case, async: false

  alias AshAgentStudio.Observe
  alias AshAgentStudio.Observe.Run
  alias AshAgentStudio.OverviewLive
  alias Phoenix.LiveView.Socket

  setup do
    Observe.clear()

    {:ok, run} =
      Observe.start_run(%{
        id: "initial",
        agent: Demo.Agent,
        provider: :req_llm,
        client: "claude",
        type: :call
      })

    {:ok, run: run}
  end

  test "mount assigns runs and handle_info refreshes", %{run: run} do
    # Pre-assign base_path as on_mount hook would do
    socket = %Socket{
      assigns: %{__changed__: %{}, flash: %{}, live_action: nil, base_path: "/ash-agent-ui"},
      private: %{}
    }

    {:ok, socket} =
      OverviewLive.mount(%{}, %{}, socket)

    assert hd(socket.assigns.runs).id == run.id
    assert socket.assigns.base_path == "/ash-agent-ui"

    new_run = %Run{
      id: "pubsub-run",
      type: :call,
      agent: Demo.Agent,
      provider: :req_llm,
      client: "claude",
      status: :running,
      started_at: DateTime.utc_now(),
      inserted_at: DateTime.utc_now(),
      events: []
    }

    {:noreply, socket} = OverviewLive.handle_info({:run_started, new_run}, socket)
    assert hd(socket.assigns.runs).id == new_run.id

    assert socket.assigns.stats.active_runs ==
             Integer.to_string(Enum.count(socket.assigns.runs, &(&1.status == :running)))
  end

  test "pauses streaming and refreshes on resume", %{run: run} do
    # Pre-assign base_path as on_mount hook would do
    socket = %Socket{
      assigns: %{__changed__: %{}, flash: %{}, live_action: nil, base_path: "/ash-agent-ui"},
      private: %{}
    }

    {:ok, socket} =
      OverviewLive.mount(%{}, %{}, socket)

    assert socket.assigns.streaming?

    {:noreply, paused} = OverviewLive.handle_event("toggle_streaming", %{}, socket)
    refute paused.assigns.streaming?
    assert hd(paused.assigns.runs).id == run.id

    {:ok, new_run} =
      Observe.start_run(%{
        id: "paused-run",
        agent: Demo.Agent,
        provider: :req_llm,
        client: "claude",
        type: :stream
      })

    {:noreply, paused_after_info} = OverviewLive.handle_info({:run_started, new_run}, paused)
    assert hd(paused_after_info.assigns.runs).id == run.id

    {:noreply, resumed} = OverviewLive.handle_event("toggle_streaming", %{}, paused_after_info)
    assert resumed.assigns.streaming?
    assert hd(resumed.assigns.runs).id == new_run.id

    assert resumed.assigns.stats.active_runs ==
             Integer.to_string(Enum.count(resumed.assigns.runs, &(&1.status == :running)))
  end
end
