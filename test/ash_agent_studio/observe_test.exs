defmodule AshAgentStudio.ObserveTest do
  use ExUnit.Case, async: false

  alias AshAgentStudio.Observe

  setup do
    # Clear store before each test
    Observe.clear()
    :ok
  end

  describe "delegations to Store" do
    test "list_runs/1 returns empty list when no runs" do
      assert {:ok, []} = Observe.list_runs()
    end

    test "start_run/1 creates a new run" do
      attrs = %{
        agent: TestModule,
        input: %{message: "test"},
        status: :running
      }

      assert {:ok, run} = Observe.start_run(attrs)
      assert is_binary(run.id)
      assert run.agent == TestModule
    end

    test "fetch_run/1 retrieves an existing run" do
      attrs = %{
        agent: FetchTestModule,
        input: %{query: "search"},
        status: :running
      }

      {:ok, created_run} = Observe.start_run(attrs)

      assert {:ok, fetched_run} = Observe.fetch_run(created_run.id)
      assert fetched_run.id == created_run.id
      assert fetched_run.agent == FetchTestModule
    end

    test "fetch_run/1 returns error tuple for non-existent run" do
      assert {:error, :not_found} = Observe.fetch_run("non-existent-id")
    end

    test "update_run/2 modifies run attributes" do
      {:ok, run} = Observe.start_run(%{agent: UpdateTest, input: %{}, status: :running})

      assert {:ok, updated} = Observe.update_run(run.id, %{status: :completed})
      assert updated.status == :completed
    end

    test "append_event/2 adds event to run" do
      {:ok, run} = Observe.start_run(%{agent: EventTest, input: %{}, status: :running})

      event = %{type: :llm_response, data: %{content: "Hello"}}
      assert {:ok, updated} = Observe.append_event(run.id, event)
      assert length(updated.events) >= 1
    end

    test "clear/0 removes all runs" do
      Observe.start_run(%{agent: ClearTest1, input: %{}, status: :running})
      Observe.start_run(%{agent: ClearTest2, input: %{}, status: :running})

      {:ok, runs_before} = Observe.list_runs()
      assert length(runs_before) >= 2

      Observe.clear()

      assert {:ok, []} = Observe.list_runs()
    end

    test "list_runs/1 supports filtering options" do
      Observe.start_run(%{agent: FilterTest, input: %{}, status: :running})
      Observe.start_run(%{agent: FilterTest, input: %{}, status: :completed})

      # Just verify it accepts options without error
      assert {:ok, runs} = Observe.list_runs(limit: 1)
      assert is_list(runs)
    end
  end
end
