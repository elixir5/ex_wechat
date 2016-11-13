defmodule ExWechat.Helpers.ParamsParser do
  @moduledoc """
    Try to generate params keyword list base on params string.
  """
  alias ExWechat.Api

  @doc """
    Parse params string to params keyword list.
  """
  def parse_params(params, module \\ Api)
  def parse_params("", _module), do: []
  def parse_params(params, module) when is_binary(params) do
    params
    |> String.split(", ")
    |> Enum.sort
    |> Enum.map(&parse_param(&1, module))
  end

  defp parse_param(param, module) do
    case String.contains?(param, "=") do
      true  ->
        [key, value] = String.split(param, "=")
        {String.to_atom(key), value}
      false ->
        key = String.to_atom(param)
        case Keyword.has_key?(module.__info__(:functions), key) do
          true   -> {key, apply(module, key, [])}
          false  -> {key, apply(Api, :get_params, [key, module])}
        end
    end
  end
end
