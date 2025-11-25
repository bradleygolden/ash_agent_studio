defmodule AshAgentStudio.Resource do
  @moduledoc """
  Extension for registering Ash agents with the Studio playground.

  Add this extension to your agent resource to make it available in the
  Ash Agent Studio playground for interactive testing.

  ## Usage

      defmodule MyApp.Agents.Summarizer do
        use Ash.Resource, extensions: [AshAgent.Resource, AshAgentStudio.Resource]

        agent do
          client "anthropic:claude-3-5-sonnet"
          # ... agent config
        end

        agent_studio do
          label "Document Summarizer"
          description "Summarizes long documents into concise summaries"
          group :content
        end
      end

  ## Options

  - `label` - Display name for the agent in the UI (defaults to module name)
  - `description` - Brief description of what the agent does
  - `group` - Optional grouping for organizing agents in the UI
  """

  use Spark.Dsl.Extension,
    sections: [AshAgentStudio.Dsl.agent_studio()],
    transformers: [AshAgentStudio.Transformers.RegisterAgent]
end
