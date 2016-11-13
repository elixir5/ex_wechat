defmodule ExWechat.Helpers.ApiHelper do
  @moduledoc """
    praser data from api description file.
  """
  import ExWechat.Helpers.ApiParser

  @api_path Path.join(__DIR__, "../apis")

  def process_api_definition_data(needed)
  def process_api_definition_data(nil) do
    process_api_definition_data(:all)
  end
  def process_api_definition_data(:all) do
    all_api_definition_data
  end
  def process_api_definition_data(needed) do
    all_api_definition_data
    |> Map.take(needed ++ [:access_token])
  end

  def all_definition_files(module) do
    module
    |> apply(:api_definition_files, [])
    |> _all_definition_files
  end

  defp _all_definition_files(user_define_path)
  defp _all_definition_files(nil) do
    all_files_in_folder(@api_path)
  end
  defp _all_definition_files(user_define_path) do
    all_files_in_folder(@api_path) ++ all_files_in_folder(user_define_path)
  end

  defp all_files_in_folder(path) do
    Path.wildcard(path <> "/*")
  end

  # get all the data of all the api definition file
  defp all_api_definition_data do
    ExWechat.Api
    |> all_definition_files
    |> _all_definition_data
  end

  defp _all_definition_data(files, result \\ %{})
  defp _all_definition_data([], result) do
    result
  end
  defp _all_definition_data([file | tail], result) do
    key = get_key_from_path(file)
    data = Map.put(result, key,
              Map.get(result, key, []) ++ (file |> api_definition_data))
    _all_definition_data(tail, data)
  end

  defp get_key_from_path(path) do
    path
    |> String.split("/")
    |> List.last
    |> String.to_atom
  end

  defp api_definition_data(path) do
    path
    |> File.stream!([], :line)
    |> Stream.map(&String.trim/1)
    |> Stream.reject(&(String.length(&1) == 0))
    |> Enum.to_list
    |> do_parse_api_data
  end
end
