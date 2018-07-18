defmodule CtiOmni.TelegramBot do
  use Agala.Bot, otp_app: :cti_omni
end





#conifg.exs
config :cti_omni, CtiOmni.TelegramBot,
  router: CtiOmni.TelegramRouter
  handler: CtiOmni.TelegramHandler
  
  
  
  
message = %{user_id, chat_id, message}


{bot_name, cid, message}

{bot_name, cid} :queue