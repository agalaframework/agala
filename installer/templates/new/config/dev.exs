use Mix.Config

# For development, we reconfigure logger
#
# Do not include metadata nor timestamps in development logs
config :logger, :console,
  level: :debug,
  format: "[$level] $message\n"
