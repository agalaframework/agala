defmodule Agala.Bot do
  @moduledoc """
  todo description about new bot
  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour Agala.Bot

      Agala.Bot.Supervisor.compile_config(__MODULE__, opts)
    end
  end

end
