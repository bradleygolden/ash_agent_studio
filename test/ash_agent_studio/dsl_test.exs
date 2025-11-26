defmodule AshAgentStudio.DslTest do
  use ExUnit.Case, async: true

  alias AshAgentStudio.Dsl

  describe "agent_studio/0" do
    test "returns agent_studio section definition" do
      section = Dsl.agent_studio()

      assert %Spark.Dsl.Section{} = section
      assert section.name == :agent_studio
    end

    test "section has only redact_fields schema option" do
      section = Dsl.agent_studio()
      schema_keys = Keyword.keys(section.schema)

      assert :redact_fields in schema_keys
      assert length(schema_keys) == 1
    end

    test "section has no entities (inputs derived from ash_agent)" do
      section = Dsl.agent_studio()

      assert section.entities == []
    end

    test "redact_fields defaults to empty list" do
      section = Dsl.agent_studio()
      redact_config = Keyword.get(section.schema, :redact_fields)

      assert redact_config[:default] == []
      assert redact_config[:type] == {:list, :atom}
    end
  end
end
