use Mix.Config

# Configuration for the application.
#
# You can use different token for testing purposes.
config :agala,
  token_env: "TEST_TELEGRAM_TOKEN"

# Print only warnings and errors during test
config :logger, level: :warn
