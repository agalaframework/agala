defmodule Agala.Provider.Telegram.PollServer do
  @moduledoc """
  Main worker module
  """

  defmacro __using__(_) do
    quote location: :keep do
      @behaviour Agala.Bot.PollServer

      require Logger
      alias Agala.BotParams

      defp get_updates_url(%BotParams{provider_params: %{token: token}}) do
        "https://api.telegram.org/bot" <> token <> "/getUpdates"
      end

      defp get_updates_body(%BotParams{private: %{offset: offset, timeout: timeout}}) do
        %{offset: offset, timeout: timeout} |> Poison.encode!
      end

      defp get_updates_options(%BotParams{private: %{http_opts: http_opts}}), do: http_opts

      def get_updates(bot_params = %BotParams{}) do
        HTTPoison.post(
          get_updates_url(bot_params),            # url
          get_updates_body(bot_params),           # body
          [{"Content-Type", "application/json"}],  # headers
          get_updates_options(bot_params)         # opts
        )
        |> parse_body
        |> resolve_updates(bot_params)
      end

      defp resolve_updates(
        {
          :ok,
          %HTTPoison.Response{
            status_code: 200,
            body: %{"ok" => true, "result" => []}
          }
        },
        bot_params
      ), do: bot_params
      defp resolve_updates(
        {
          :error,
          %HTTPoison.Error{
            id: nil,
            reason: :timeout
          }
        },
        bot_params
      ) do
        # This is just failed long polling, simply restart
        Logger.debug("Long polling request ended with timeout, resend to poll")
        bot_params
      end

      defp resolve_updates(
        {
          :ok,
          %HTTPoison.Response{
            status_code: 200,
            body: %{"ok" => true, "result" => result}
          }
        },
        bot_params
      ) do
        Logger.debug fn -> "Response body is:\n #{inspect(result)}" end
        result
        |> process_messages(bot_params)
      end
      defp resolve_updates({:ok, %HTTPoison.Response{status_code: status_code}}, bot_params) do
        Logger.warn("HTTP response ended with status code #{status_code}")
        bot_params
      end
      defp resolve_updates({:error, err}, bot_params) do
        Logger.warn("#{inspect err}")
        bot_params
      end

      defp parse_body({:ok, resp = %HTTPoison.Response{body: body}}) do
        {:ok, %HTTPoison.Response{resp | body: Poison.decode!(body)}}
      end
      defp parse_body(default), do: default

      defp process_messages([message] = [%{"update_id"=>offset}], bot_params) do
        process_message(message, bot_params)
        #last message, so the offset is moving to +1
        put_in(bot_params, [:private, :offset], offset + 1)
      end
      defp process_messages([h|t], bot_params) do
        process_message(h, bot_params)
        process_messages(t, bot_params)
      end


      defp process_message(message, bot_params) do
        # Cast received message to handle bank, there the message
        # will be proceeded throw handlers pipe
        Agala.Bot.PollHandler.cast_to_handle(
          message,
          bot_params
        )
      end

    end
  end
end
