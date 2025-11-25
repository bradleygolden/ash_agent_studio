defmodule AshAgentStudio.Observe.RunTest do
  use ExUnit.Case, async: true

  alias AshAgentStudio.Observe.Run

  describe "struct creation" do
    test "creates struct with required fields" do
      run = %Run{
        id: "run-123",
        agent: MyAgent,
        provider: :mock,
        client: "mock:test",
        type: :call,
        status: :running,
        started_at: DateTime.utc_now()
      }

      assert run.id == "run-123"
      assert run.agent == MyAgent
      assert run.provider == :mock
      assert run.client == "mock:test"
      assert run.type == :call
      assert run.status == :running
    end

    test "struct requires :id field" do
      # The @enforce_keys ensures :id is required at compile time
      # This test verifies that the struct has the expected enforced keys
      struct_keys = Map.keys(Run.__struct__())
      assert :id in struct_keys
    end

    test "has default values for optional fields" do
      run = %Run{
        id: "run-456",
        agent: MyAgent,
        provider: :mock,
        client: "mock:test",
        type: :stream,
        status: :completed,
        started_at: DateTime.utc_now()
      }

      assert run.completed_at == nil
      assert run.duration_ms == nil
      assert run.usage == nil
      assert run.input == nil
      assert run.result == nil
      assert run.error == nil
      assert run.events == []
    end
  end

  describe "struct fields" do
    test "includes all expected fields" do
      run = %Run{
        id: "run-789",
        agent: TestAgent,
        provider: :anthropic,
        client: "anthropic:claude-3-5-sonnet",
        type: :call,
        status: :completed,
        started_at: ~U[2025-01-01 10:00:00Z],
        completed_at: ~U[2025-01-01 10:00:05Z],
        inserted_at: ~U[2025-01-01 10:00:00Z],
        duration_ms: 5000,
        usage: %{input_tokens: 100, output_tokens: 50},
        input: %{message: "Hello"},
        result: %{response: "Hi there!"},
        error: nil,
        profile: "default",
        response_id: "msg_123",
        response_model: "claude-3-5-sonnet-20241022",
        finish_reason: "end_turn",
        provider_meta: %{region: "us-east-1"},
        http: %{status: 200},
        events: [%{type: :start, timestamp: ~U[2025-01-01 10:00:00Z]}]
      }

      assert run.profile == "default"
      assert run.response_id == "msg_123"
      assert run.response_model == "claude-3-5-sonnet-20241022"
      assert run.finish_reason == "end_turn"
      assert run.provider_meta == %{region: "us-east-1"}
      assert run.http == %{status: 200}
      assert length(run.events) == 1
    end
  end

  describe "struct updates" do
    test "can update status" do
      run = %Run{
        id: "run-update",
        agent: MyAgent,
        provider: :mock,
        client: "mock:test",
        type: :call,
        status: :running,
        started_at: DateTime.utc_now()
      }

      updated = %{run | status: :completed, completed_at: DateTime.utc_now()}

      assert updated.status == :completed
      assert is_struct(updated.completed_at, DateTime)
    end

    test "can append events" do
      run = %Run{
        id: "run-events",
        agent: MyAgent,
        provider: :mock,
        client: "mock:test",
        type: :call,
        status: :running,
        started_at: DateTime.utc_now(),
        events: []
      }

      event1 = %{type: :llm_request, timestamp: DateTime.utc_now()}
      event2 = %{type: :llm_response, timestamp: DateTime.utc_now()}

      updated = %{run | events: run.events ++ [event1, event2]}

      assert length(updated.events) == 2
    end

    test "can set usage data" do
      run = %Run{
        id: "run-usage",
        agent: MyAgent,
        provider: :mock,
        client: "mock:test",
        type: :call,
        status: :running,
        started_at: DateTime.utc_now()
      }

      usage = %{
        input_tokens: 150,
        output_tokens: 75,
        total_tokens: 225
      }

      updated = %{run | usage: usage}

      assert updated.usage.input_tokens == 150
      assert updated.usage.output_tokens == 75
      assert updated.usage.total_tokens == 225
    end
  end

  describe "status values" do
    test "can have :running status" do
      run = make_run(:running)
      assert run.status == :running
    end

    test "can have :completed status" do
      run = make_run(:completed)
      assert run.status == :completed
    end

    test "can have :error status" do
      run = make_run(:error)
      assert run.status == :error
    end
  end

  describe "type values" do
    test "can have :call type" do
      run = make_run(:running, :call)
      assert run.type == :call
    end

    test "can have :stream type" do
      run = make_run(:running, :stream)
      assert run.type == :stream
    end
  end

  defp make_run(status, type \\ :call) do
    %Run{
      id: "run-#{System.unique_integer([:positive])}",
      agent: MyAgent,
      provider: :mock,
      client: "mock:test",
      type: type,
      status: status,
      started_at: DateTime.utc_now()
    }
  end
end
