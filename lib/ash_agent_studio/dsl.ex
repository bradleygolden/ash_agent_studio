defmodule AshAgentStudio.Dsl do
  @moduledoc """
  DSL definitions for AshAgentStudio extension.

  Provides the `agent_studio` section for registering agents with the studio playground.
  """

  @input %Spark.Dsl.Entity{
    name: :input,
    describe: "Defines an input argument for the agent playground.",
    target: AshAgentStudio.Dsl.Input,
    args: [:name],
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "The name of the input argument."
      ],
      type: [
        type: {:one_of, [:string, :integer, :float, :boolean, :map, :list]},
        default: :string,
        doc: "The type of the input argument."
      ],
      doc: [
        type: :string,
        required: false,
        doc: "Description of what this input is for."
      ],
      default: [
        type: :any,
        required: false,
        doc: "Default value for this input."
      ],
      allow_nil?: [
        type: :boolean,
        default: true,
        doc: "Whether this input can be nil/empty."
      ]
    ]
  }

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

        input :document, type: :string, doc: "The document to summarize"
        input :max_length, type: :integer, default: 100, doc: "Maximum summary length"
      end
      """
    ],
    entities: [@input],
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
      ],
      redact_fields: [
        type: {:list, :atom},
        default: [],
        doc: "List of field names to redact in studio UI (replaced with [REDACTED])."
      ]
    ]
  }

  def agent_studio, do: @agent_studio
end

defmodule AshAgentStudio.Dsl.Input do
  @moduledoc """
  Struct representing an input argument for the agent playground.
  """
  defstruct [:name, :type, :doc, :default, :allow_nil?, __spark_metadata__: nil]
end
