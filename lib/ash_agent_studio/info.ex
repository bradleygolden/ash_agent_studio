defmodule AshAgentStudio.Info do
  @moduledoc """
  Introspection functions for AshAgentStudio extension.
  """

  alias Spark.Dsl.Extension

  @spec redact_fields(Ash.Resource.t()) :: [atom()]
  def redact_fields(resource) do
    Extension.get_opt(resource, [:agent_studio], :redact_fields, [])
  end
end
