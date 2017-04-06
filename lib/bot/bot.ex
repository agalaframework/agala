defmodule Agala.Bot do
  use HTTPoison.Base
  require Logger

  @default_router Agala.Router.Direct

  @moduledoc """
  Main worker module
  """
  def process_url(url) do
    "https://api.telegram.org/bot" <> Agala.get_token <> "/" <> url
  end

  def getUpdates(%{timeout: timeout, offset: offset}) do
    "getUpdates"
    |> exec_cmd(%{timeout: timeout, offset: offset})
    |> resolve_updates
  end

  def resolve_updates({
    offset,
    {
      :ok,
      %HTTPoison.Response{
        status_code: 200,
        body: %{"ok" => true, "result" => []}
      }
    }
  }) do
    offset
  end
  def resolve_updates({
    _offset,
    {
      :ok,
      %HTTPoison.Response{
        status_code: 200,
        body: %{"ok" => true, "result" => result}
      }
    }
  }) do
    Logger.debug "Response body is:\n #{inspect(result)}"
    result
    |> process_messages
  end
  def resolve_updates({offset, {:ok, %HTTPoison.Response{status_code: status_code}}}) do
    Logger.warn("HTTP response ended with status code #{status_code}")
    offset
  end
  def resolve_updates({offset, {:error, %HTTPoison.Error{id: nil, reason: :timeout}}}) do
    # This is just failed long polling, simply restart
    Logger.info("Long polling request failed, resend")
    offset
  end
  def resolve_updates({offset, {:error, err}}) do
    Logger.warn("#{inspect err}")
    offset
  end

  def exec_cmd(cmd, params = %{offset: offset}) do
    {offset, get(cmd, [], params: params)}
  end

  def exec_cmd(cmd, params) do
    get(cmd, [], params: params)
  end

  def process_response_body(body) do
     body
     |> Poison.decode!
  end

  def process_messages([message] = [%{"update_id"=>offset}]) do
    process_message(message)
    #last message, so the offset is moving to +1
    offset + 1
  end

  def process_messages([h|t]) do
    process_message(h)
    process_messages(t)
  end

  def process_message(message) do
    Task.Supervisor.start_child(Agala.Bot.TasksSupervisor, fn ->
      Agala.get_router().route(message)
    end)
  end
end
