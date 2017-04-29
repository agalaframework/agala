use Mix.Config

config :agala,
  token: {:system, "TELEGRAM_TOKEN"},
  router: Agala.Router.User,
  handler: Agala.Handler.Echo,
  request_timeout: 5000

config :agala, Agala.Handler.Broadcast,
  chat_id: "-1001072726818"
