defmodule AshAgentStudio.Dsl do
  @moduledoc """
  DSL definitions for AshAgentStudio extension.

  Provides the `agent_studio` section for registering agents with the studio playground.
  """

  @agent_studio %Spark.Dsl.Section{
    name: :agent_studio,
    describe: """
    Configuration for registering this agent with Ash Agent Studio.

    Agents with this section will appear in the Studio playground,
    allowing interactive testing with dynamically generated input forms.
    """,
    examples: [
      """
      agent_studio do
        label "Document Summarizer"
        description "Summarizes long documents into concise summaries"
        group :content
      end
      """
    ],
    schema: [
      label: [
        type: :string,
        required: false,
        doc: "Display name for the agent in the studio UI. Defaults to the module name."
      ],
      description: [
        type: :string,
        required: false,
        doc: "Brief description of what the agent does."
      ],
      group: [
        type: :atom,
        required: false,
        doc: "Optional grouping for organizing agents in the UI."
      ]
    ]
  }

  def agent_studio, do: @agent_studio
end
