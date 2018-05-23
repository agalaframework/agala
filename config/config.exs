use Mix.Config

config :agala,
  backbone: Agala.Backbone.RabbitMQ

config :agala, Agala.Backbone.RabbitMQ,
  domain: :agala,
  pool_size: 5,
  host: "192.168.100.200",
  username: "rabbit",
  password: "rabbit"
