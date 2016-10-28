use Mix.Config

config :agala, 
  token_env: "TELEGRAM_TOKEN",
  router: Agala.Router.User,
  handler: Agala.Handler.Echo

config :agala, Agala.Handler.Broadcast,
  chat_id: "-1001072726818"


  #Application.get_env(:agala, Agala.Handler.Broadcast)[:chat_id]