defmodule AshAgentStudio.Resource do
  @moduledoc """
  Extension for registering Ash agents with the Studio playground.

  Add this extension to your agent resource to make it available in the
  Ash Agent Studio playground for interactive testing.

  ## Automatic Configuration

  The following are automatically derived:
  - **Label**: From module name (e.g., `MyApp.ChatAgent` → "Chat Agent")
  - **Description**: From `@moduledoc` (first paragraph)
  - **Inputs**: From `ash_agent` argument definitions (uses the `doc` field)

  ## Usage

  Simplest - just add the extension (no block needed):

      defmodule MyApp.Agents.Summarizer do
        @moduledoc "Summarizes documents into key points."

        use Ash.Resource, extensions: [AshAgent.Resource, AshAgentStudio.Resource]

        agent do
          client "anthropic:claude-3-5-sonnet"

          input do
            argument :document, :string, allow_nil?: false, doc: "Document to summarize"
          end
        end
      end

  With additional field redaction:

      defmodule MyApp.Agents.Summarizer do
        @moduledoc "Summarizes documents into key points."

        use Ash.Resource, extensions: [AshAgent.Resource, AshAgentStudio.Resource]

        agent do
          client "anthropic:claude-3-5-sonnet"

          input do
            argument :document, :string, allow_nil?: false, doc: "Document to summarize"
            argument :api_key, :string, sensitive?: true  # Auto-redacted
          end
        end

        agent_studio do
          redact_fields [:internal_id]  # Additional manual redaction
        end
      end

  ## Options

  - `redact_fields` - List of additional field names to redact in the UI.
    Fields marked with `sensitive?: true` in ash_agent are automatically redacted.
  """

  use Spark.Dsl.Extension,
    sections: [AshAgentStudio.Dsl.agent_studio()],
    transformers: [AshAgentStudio.Transformers.RegisterAgent]
end
