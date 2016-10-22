use Mix.Config

# For production, we configure telegram token for deployment
config :agala,
  token_env: "TELEGRAM_TOKEN"

# Do not print debug messages in production
config :logger, level: :info

