defmodule AshAgentStudio.Dsl do
  @moduledoc """
  DSL definitions for AshAgentStudio extension.

  Provides the `agent_studio` section for registering agents with the studio playground.
  Configuration like label, description, and inputs are automatically derived from
  the agent module and ash_agent DSL.
  """

  @agent_studio %Spark.Dsl.Section{
    name: :agent_studio,
    describe: """
    Configuration for registering this agent with Ash Agent Studio.

    Agents with this extension will appear in the Studio playground.
    Label is derived from the module name, description from @moduledoc,
    and inputs from the ash_agent argument definitions.
    """,
    examples: [
      """
      # Minimal - just enable studio integration (block can be omitted entirely)
      agent_studio do
      end
      """,
      """
      # With additional field redaction
      agent_studio do
        redact_fields [:api_key, :secret]
      end
      """
    ],
    entities: [],
    schema: [
      redact_fields: [
        type: {:list, :atom},
        default: [],
        doc:
          "List of field names to redact in studio UI (replaced with [REDACTED]). Fields marked as sensitive? in ash_agent are automatically redacted."
      ]
    ]
  }

  def agent_studio, do: @agent_studio
end
