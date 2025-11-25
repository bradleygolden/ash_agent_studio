defmodule AshAgentStudio.DslTest do
  use ExUnit.Case, async: true

  alias AshAgentStudio.Dsl
  alias AshAgentStudio.Dsl.Input

  describe "agent_studio/0" do
    test "returns agent_studio section definition" do
      section = Dsl.agent_studio()

      assert %Spark.Dsl.Section{} = section
      assert section.name == :agent_studio
    end

    test "section has expected schema options" do
      section = Dsl.agent_studio()
      schema_keys = Keyword.keys(section.schema)

      assert :label in schema_keys
      assert :description in schema_keys
      assert :group in schema_keys
    end

    test "section has input entity" do
      section = Dsl.agent_studio()
      entity_names = Enum.map(section.entities, & &1.name)

      assert :input in entity_names
    end

    test "input entity has correct schema" do
      section = Dsl.agent_studio()
      [input_entity] = section.entities

      assert input_entity.name == :input
      assert input_entity.target == Input

      schema_keys = Keyword.keys(input_entity.schema)
      assert :name in schema_keys
      assert :type in schema_keys
      assert :doc in schema_keys
      assert :default in schema_keys
      assert :allow_nil? in schema_keys
    end
  end

  describe "Input struct" do
    test "has expected fields" do
      input = %Input{
        name: :message,
        type: :string,
        doc: "The user message",
        default: nil,
        allow_nil?: true
      }

      assert input.name == :message
      assert input.type == :string
      assert input.doc == "The user message"
      assert input.default == nil
      assert input.allow_nil? == true
    end

    test "default values are nil when not specified" do
      input = %Input{name: :test, type: :string}

      assert input.doc == nil
      assert input.default == nil
      assert input.allow_nil? == nil
    end

    test "supports various types" do
      types = [:string, :integer, :float, :boolean, :map, :list]

      for type <- types do
        input = %Input{name: :test, type: type}
        assert input.type == type
      end
    end
  end
end
