defmodule Agala.Provider.Telegram do
  @moduledoc """
  smth
  """
  use Agala.Provider

  @spec child_spec(
    mode :: :poller | :plug | :handler,
    bot :: Agala.Bot.t(),
    opts :: Keyword.t()
  ) :: map()
  def child_spec(:poller, bot, opts) do
    %{
      id: Module.concat(bot, Poller),
      start: {Agala.Provider.Telegram.Poller, :start_link, [bot, opts]},
      type: :worker
    }
  end
end
