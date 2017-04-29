defmodule Agala.Bot do
  require Logger
  alias Agala.Bot.PollerParams

  @moduledoc """
  Main worker module
  """

  def get_updates_url(%PollerParams{token: token}) do
    "https://api.telegram.org/bot" <> token <> "/getUpdates"
  end

  def get_updates_body(%PollerParams{offset: offset, timeout: timeout}) do
    %{offset: offset, timeout: timeout} |> Poison.encode!
  end

  def get_updates_options(%PollerParams{http_opts: http_opts}), do: http_opts

  def get_updates(poller_params = %Agala.Bot.PollerParams{}) do
    HTTPoison.post(
      get_updates_url(poller_params),     # url
      get_updates_body(poller_params),    # body
      [],                                 # headers
      get_updates_options(poller_params)  # opts
    )
    |> parse_body
    |> resolve_updates(poller_params)
  end

  def resolve_updates(
    {
      :ok,
      %HTTPoison.Response{
        status_code: 200,
        body: %{"ok" => true, "result" => []}
      }
    },
    poller_params
  ), do: poller_params
  def resolve_updates(
    {
      :error,
      %HTTPoison.Error{
        id: nil,
        reason: :timeout
      }
    },
    poller_params
  ) do
    # This is just failed long polling, simply restart
    Logger.debug("Long polling request ended with timeout, resend to poll")
    poller_params
  end

  def resolve_updates(
    {
      :ok,
      %HTTPoison.Response{
        status_code: 200,
        body: %{"ok" => true, "result" => result}
      }
    },
    poller_params
  ) do
    Logger.debug "Response body is:\n #{inspect(result)}"
    result
    |> process_messages(poller_params)
  end
  def resolve_updates({:ok, %HTTPoison.Response{status_code: status_code, body: body}}, poller_params) do
    Logger.warn("HTTP response ended with status code #{status_code}")

    poller_params
  end
  def resolve_updates({:error, err}, poller_params) do
    Logger.warn("#{inspect err}")
    poller_params
  end

  def parse_body({:ok, resp = %HTTPoison.Response{body: body}}) do
    {:ok, %HTTPoison.Response{resp | body: Poison.decode!(body)}}
  end
  def parse_body(default), do: default

  def process_messages([message] = [%{"update_id"=>offset}], poller_params) do
    process_message(message, poller_params)
    #last message, so the offset is moving to +1
    %PollerParams{poller_params | offset: offset+1 }
  end
  def process_messages([h|t], poller_params) do
    process_message(h, poller_params)
    process_messages(t, poller_params)
  end
  defp process_message(message, params = %PollerParams{router: router}), do: router.route(message, params)
end
