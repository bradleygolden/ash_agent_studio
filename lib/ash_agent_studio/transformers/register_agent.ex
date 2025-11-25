defmodule AshAgentStudio.Transformers.RegisterAgent do
  @moduledoc """
  Transformer that registers agents with the AshAgentStudio.Registry at compile time.
  """

  use Spark.Dsl.Transformer

  def after?(_), do: true

  def transform(dsl_state) do
    module = Spark.Dsl.Transformer.get_persisted(dsl_state, :module)

    config = %{
      label:
        Spark.Dsl.Transformer.get_option(dsl_state, [:agent_studio], :label) ||
          default_label(module),
      description: Spark.Dsl.Transformer.get_option(dsl_state, [:agent_studio], :description),
      group: Spark.Dsl.Transformer.get_option(dsl_state, [:agent_studio], :group)
    }

    # Register at runtime when the module is loaded
    dsl_state =
      Spark.Dsl.Transformer.eval(
        dsl_state,
        [],
        quote do
          def __ash_agent_studio_config__ do
            unquote(Macro.escape(config))
          end

          # Register with the registry when the module is first called
          @after_compile {AshAgentStudio.Transformers.RegisterAgent, :register_agent}
        end
      )

    {:ok, dsl_state}
  end

  def register_agent(env, _bytecode) do
    if Process.whereis(AshAgentStudio.Registry) do
      config = env.module.__ash_agent_studio_config__()
      AshAgentStudio.Registry.register(env.module, config)
    end
  end

  defp default_label(module) do
    module
    |> Module.split()
    |> List.last()
    |> Macro.underscore()
    |> String.replace("_", " ")
    |> String.split()
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end
end
