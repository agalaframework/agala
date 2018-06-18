defmodule Agala.Provider.Dummy do
  use Agala.Provider

  def child_spec(:poller, bot, opts) do
    %{
      id: Module.concat(bot, Poller),
    }
  end
end
