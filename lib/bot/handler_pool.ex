defmodule Agala.Bot.HandlerPool do
  defp via_tuple(name) do
    {:via, Registry, {Agala.Registry, {:handler_pool, name}}}
  end
  defp config(name, pool_size) do
    [
      name: via_tuple(name),
      worker_module: Agala.Bot.Handler,
      size: pool_size,
      max_overflow: pool_size
    ]
  end
  def child_spec(bot_params = %{name: name, handler_pool: pool_size}) do
    :poolboy.child_spec(
      via_tuple(name),              # name
      config(name, pool_size),      # pool_options
      bot_params                    # worker start params
    )
  end

  def handle(message, bot_params = %Agala.BotParams{name: name}) do
    spawn fn ->
      :poolboy.transaction(
        via_tuple(name),
        fn(pid) ->
          Agala.Bot.Handler.proceed_sync(pid, message, bot_params)
        end
      )
    end
  end
end
