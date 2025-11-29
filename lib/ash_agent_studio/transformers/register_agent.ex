defmodule AshAgentStudio.Transformers.RegisterAgent do
  @moduledoc """
  Transformer that registers agents with the AshAgentStudio.Registry at compile time.

  Derives configuration from:
  - Label: Module name converted to human-readable form (snake_case → Title Case)
  - Description: @moduledoc of the agent module (first paragraph)
  - Inputs: argument entities from ash_agent DSL (uses the `doc` field)
  """

  use Spark.Dsl.Transformer

  def after?(_), do: true

  def transform(dsl_state) do
    module = Spark.Dsl.Transformer.get_persisted(dsl_state, :module)

    # Derive inputs from ash_agent's argument entities
    inputs = derive_inputs_from_ash_agent(dsl_state)

    # Pre-compute the label at transformer time
    label = default_label(module)

    dsl_state =
      Spark.Dsl.Transformer.eval(
        dsl_state,
        [],
        quote do
          def __ash_agent_studio_config__ do
            # Extract description from @moduledoc at compile time
            description =
              AshAgentStudio.Transformers.RegisterAgent.extract_moduledoc_description(@moduledoc)

            %{
              label: unquote(label),
              description: description,
              inputs: unquote(Macro.escape(inputs))
            }
          end

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
    input_schema = Spark.Dsl.Transformer.get_option(dsl_state, [:agent], :input_schema)

    case input_schema do
      nil -> []
      schema -> extract_fields_from_zoi_schema(schema)
    end
  rescue
    _ -> []
  end

  defp extract_fields_from_zoi_schema(%{of: fields}) when is_map(fields) do
    Enum.map(fields, fn {name, field_schema} ->
      %{
        name: name,
        type: infer_type(field_schema),
        doc: nil,
        default: extract_default(field_schema),
        allow_nil?: optional?(field_schema)
      }
    end)
  end

  defp extract_fields_from_zoi_schema(_), do: []

  defp infer_type(%{type: :string}), do: :string
  defp infer_type(%{type: :integer}), do: :integer
  defp infer_type(%{type: :float}), do: :float
  defp infer_type(%{type: :boolean}), do: :boolean
  defp infer_type(%{type: :map}), do: :map
  defp infer_type(%{type: :list}), do: :list
  defp infer_type(_), do: :string

  defp extract_default(%{default: default}), do: default
  defp extract_default(_), do: nil

  defp optional?(%{optional: true}), do: true
  defp optional?(%{nullable: true}), do: true
  defp optional?(_), do: false

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
