defmodule AshAgentStudio.Domain do
  @moduledoc """
  A domain extension to configure which domains appear in the Agent Studio playground.

  Add this extension to your domain to make its agents available in the playground.

  ## Usage

      defmodule MyApp.Domain do
        use Ash.Domain,
          extensions: [AshAgent.Domain, AshAgentStudio.Domain]

        agent_studio do
          show? true
        end

        resources do
          resource MyApp.ChatAgent
        end
      end

  ## Options

  - `show?` - Whether this domain's agents should appear in the studio playground (default: false)
  """

  @agent_studio %Spark.Dsl.Section{
    name: :agent_studio,
    describe: "Configure the agent studio for a given domain.",
    schema: [
      show?: [
        type: :boolean,
        default: false,
        doc: "Whether this domain's agents should appear in the studio playground."
      ]
    ]
  }

  alias Spark.Dsl.Extension

  use Extension,
    sections: [@agent_studio]

  def show?(domain) do
    Extension.get_opt(domain, [:agent_studio], :show?, false, true)
  end
end
