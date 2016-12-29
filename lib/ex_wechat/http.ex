defmodule ExWechat.Http do
  @moduledoc """
  Http request module

  Tery to make test easy.
  """

  @doc """
  Do http get request with HTTPoison.

  Use a callback method to parse the reponse, and controll the error handling
  """
  def get(options, callback \\ &(&1)) do
    [url: url, params: params] = options

    # use test default value to make test easy, only modify by the HttpTestCase
    default = get_test_default_value(url, params)

    if default do
      default
    else
      :get
      |> httpoison([url, [], gen_opts(params)])
      |> callback.()
    end
  end

  @doc """
  Do http post request with HTTPoison.
  """
  def post(options, callback \\ &(&1)) do
    [url: url, body: body, params: params] = options

    # use test default value to make test easy, only modify by the HttpTestCase
    default = get_test_default_value(url, params)

    if default do
      default
    else
      :post
      |> httpoison([url, encode_post_body(body), [], gen_opts(params)])
      |> callback.()
    end
  end

  @doc """
  Parse responde body, define for api, able to re-run the api functions.
  """
  def parse_response(response, module, name, body \\ nil, params)
  def parse_response({:error, error}, _, _, _, _), do: %{error: error.reason}
  def parse_response({:ok, response}, _, _, _, _), do: response.body |> process_body

  defp httpoison(verb, opts) do
    apply(HTTPoison, verb, opts)
  end

  defp gen_opts(params) do
    [params: params, hackney: [pool: :wechat_pool]]
  end

  defp process_body(body)
  defp process_body("{" <> _ = body), do: Poison.decode!(body, keys: :atoms)
  defp process_body(body), do: body

  # encode post request body
  defp encode_post_body(body)
  defp encode_post_body(nil), do: nil
  defp encode_post_body(body) when is_binary(body), do: body
  defp encode_post_body(body) when is_map(body), do: Poison.encode!(body)

  # get test default value
  def get_test_default_value(url, params) do
    if Mix.env == :test do
      ExWechat.Tools.HttpCase.get(url, params)
    else
      []
    end
  end
end
