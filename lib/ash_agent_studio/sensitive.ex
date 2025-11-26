defmodule AshAgentStudio.Sensitive do
  @moduledoc """
  Utilities for redacting sensitive data in studio UI.
  """

  @redacted "[REDACTED]"

  @spec redact(map(), [atom()]) :: map()
  def redact(data, fields) when is_map(data) and is_list(fields) do
    Enum.reduce(fields, data, &redact_field/2)
  end

  def redact(data, _fields), do: data

  defp redact_field(field, acc) do
    string_key = to_string(field)

    cond do
      Map.has_key?(acc, field) -> Map.put(acc, field, @redacted)
      Map.has_key?(acc, string_key) -> Map.put(acc, string_key, @redacted)
      true -> acc
    end
  end

  @spec redact_deep(term(), [atom()]) :: term()
  def redact_deep(data, fields) when is_map(data) and is_list(fields) do
    data
    |> redact(fields)
    |> Map.new(fn {k, v} -> {k, redact_deep(v, fields)} end)
  end

  def redact_deep(data, fields) when is_list(data) do
    Enum.map(data, &redact_deep(&1, fields))
  end

  def redact_deep(data, _fields), do: data

  @spec redacted_value() :: String.t()
  def redacted_value, do: @redacted
end
