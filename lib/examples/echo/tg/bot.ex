defmodule Agala.Examples.Echo.Tg.Bot do
  use Agala.Bot.Poller,
    otp_app: :example,
    provider: Agala.Provider.Telegram,
    chain: Agala.Examples.Echo.Tg.Chain
end
