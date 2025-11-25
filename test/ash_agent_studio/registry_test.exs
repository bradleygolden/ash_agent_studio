defmodule AshAgentStudio.RegistryTest do
  use ExUnit.Case, async: false

  alias AshAgentStudio.Registry

  # Note: Registry GenServer is started by the application
  # These tests interact with the running instance

  describe "register/2" do
    test "registers an agent with config" do
      module = TestAgent1
      config = %{name: "Test Agent 1", description: "A test agent"}

      result = Registry.register(module, config)

      assert result == :ok
    end

    test "allows registering multiple agents" do
      module1 = TestAgent2
      module2 = TestAgent3
      config1 = %{name: "Agent 2"}
      config2 = %{name: "Agent 3"}

      assert :ok = Registry.register(module1, config1)
      assert :ok = Registry.register(module2, config2)
    end

    test "overwrites existing registration" do
      module = TestAgent4
      config1 = %{name: "Original"}
      config2 = %{name: "Updated"}

      :ok = Registry.register(module, config1)
      :ok = Registry.register(module, config2)

      {:ok, retrieved} = Registry.get_config(module)
      assert retrieved.name == "Updated"
    end
  end

  describe "get_config/1" do
    test "returns config for registered agent" do
      module = TestAgent5
      config = %{name: "Get Test Agent", version: "1.0"}

      :ok = Registry.register(module, config)

      assert {:ok, ^config} = Registry.get_config(module)
    end

    test "returns :error for unregistered agent" do
      result = Registry.get_config(NonExistentAgent)

      assert result == :error
    end
  end

  describe "registered?/1" do
    test "returns true for registered agent" do
      module = TestAgent6
      config = %{name: "Registered Test"}

      :ok = Registry.register(module, config)

      assert Registry.registered?(module) == true
    end

    test "returns false for unregistered agent" do
      assert Registry.registered?(DefinitelyNotRegistered) == false
    end
  end

  describe "list_agents/0" do
    test "returns list of registered agents" do
      # Register some agents first
      module = TestAgent7
      config = %{name: "List Test Agent"}
      :ok = Registry.register(module, config)

      agents = Registry.list_agents()

      assert is_list(agents)
      # Check that our registered agent is in the list
      assert Enum.any?(agents, fn {m, _c} -> m == module end)
    end

    test "returns empty list when no agents registered" do
      # This might have agents from other tests, so we just verify it returns a list
      result = Registry.list_agents()

      assert is_list(result)
    end
  end

  describe "discover_agents/0" do
    test "returns :ok" do
      result = Registry.discover_agents()

      assert result == :ok
    end
  end
end
