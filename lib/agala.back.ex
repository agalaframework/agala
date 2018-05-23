defmodule Agala.Back do
  @moduledoc """
  Main framework module. Basic `Application`. Should be started as external application
  in your `mix.exs` file in order to use **Agala**.
  """

  @doc """
  Function in the global scope. Starts the navigation process of the response.
  Calling this function will send the response to nesessery bot across the cluster.

  Handler's response is automaticly casted to this function.

  ## Params
    * `conn` - `Agala.Conn` with populated `Agala.Conn.Response`.
  """
  @spec response_with(conn :: Agala.Conn.t) :: :ok
  defdelegate response_with(conn), to: Agala.Bot.Responser, as: :response

  ### Storage

  @doc """
  Sets given `value` under given `key` across bot's supervisor lifetime.
  Can be usefull to store some state across restarting handlers, responsers
  and receivers.
  """
  def set(bot_params, key, value) do
    bot_params.storage.set(bot_params, key, value)
  end

  @doc """
  Gets the value, stored under the given `key` across bot's supervisor lifetime.
  Can be usefull to reveal some state across restarting handlers, responsers
  and receivers.
  """
  def get(bot_params, key) do
    bot_params.storage.get(bot_params, key)
  end

  @doc """
  This method provides functionality to send request and get response
  to bot responser's provider. You can use it in order to call method out of request-response
  cycle. For example - to get additional parameters from provider's entity.

  ### Examples

      Agala.execute(fn conn -> Users.get(conn, user_ids, fields, name_case) end, bot_params)
  """
  @spec execute(fun :: (Agala.Conn.t -> any), bot_params :: Agala.BotParams.t) :: any
  def execute(fun, bot_params) do
    {:ok, bot_params} = bot_params
    |> bot_params.provider.init(:responser)

    fun.(%Agala.Conn{})
    |> Agala.Conn.send_to(bot_params.name)
    |> bot_params.provider.get_responser().response(bot_params)
  end
end
