defmodule AshAgentStudio.Transformers.RegisterAgent do
  @moduledoc """
  Transformer that registers agents with the AshAgentStudio.Registry at compile time.

  Derives configuration from:
  - Label: Module name converted to human-readable form (snake_case → Title Case)
  - Description: @moduledoc of the agent module (first paragraph)
  - Inputs: argument entities from ash_agent DSL (uses the `doc` field)
  """

  use Spark.Dsl.Transformer

  alias Spark.Dsl.Transformer

  def after?(_), do: true

  def transform(dsl_state) do
    module = Transformer.get_persisted(dsl_state, :module)

    # Derive inputs from ash_agent's argument entities
    inputs = derive_inputs_from_ash_agent(dsl_state)

    # Pre-compute the label at transformer time
    label = default_label(module)

    dsl_state =
      Transformer.eval(
        dsl_state,
        [],
        quote do
          def __ash_agent_studio_config__ do
            # Extract description from @moduledoc at compile time
            description =
              unquote(__MODULE__).extract_moduledoc_description(@moduledoc)

            %{
              label: unquote(label),
              description: description,
              inputs: unquote(Macro.escape(inputs))
            }
          end

          @after_compile {unquote(__MODULE__), :register_agent}
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

  @doc """
  Extracts the first paragraph from a module's @moduledoc attribute.
  Returns nil if no documentation is present.
  """
  @spec extract_moduledoc_description(term()) :: String.t() | nil
  def extract_moduledoc_description(moduledoc) do
    case moduledoc do
      nil -> nil
      false -> nil
      {_line, doc} when is_binary(doc) -> first_paragraph(doc)
      doc when is_binary(doc) -> first_paragraph(doc)
      _ -> nil
    end
  end

  defp first_paragraph(doc) do
    doc
    |> String.split(~r/\n\n/, parts: 2)
    |> List.first()
    |> String.trim()
  end

  defp derive_inputs_from_ash_agent(dsl_state) do
    # Try to get argument entities from ash_agent's input section
    dsl_state
    |> Transformer.get_entities([:agent, :input])
    |> Enum.map(fn arg ->
      %{
        name: arg.name,
        type: arg.type,
        doc: arg.doc,
        default: arg.default,
        allow_nil?: arg.allow_nil?
      }
    end)
  rescue
    # If ash_agent extension is not present, return empty list
    _ -> []
  end

  # Follows ash_admin pattern: snake_case → Title Case
  defp default_label(module) do
    module
    |> Module.split()
    |> List.last()
    |> Macro.underscore()
    |> String.split("_")
    |> Enum.map_join(" ", &String.capitalize/1)
  end
end
