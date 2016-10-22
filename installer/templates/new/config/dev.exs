use Mix.Config

# Configuration for the application.
#
# You can use different token for development purposes.
config :agala,
  token_env: "DEV_TELEGRAM_TOKEN"

# For development, we reconfigure logger
#
# Do not include metadata nor timestamps in development logs
config :logger, :console,
  level: :debug,
  format: "[$level] $message\n"

