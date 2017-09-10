defmodule <%= app_module %>.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Add here as many bot instances as you want. Dont forget to name there uniqly.
    children = [
      supervisor(Agala.Bot, [bot_configuration()])
    ]

    opts = [strategy: :one_for_one, name: <%= app_module %>.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
  This function helps you to configure your first bot. `name`, `provider`, `handler` fields
  are mandatory. `provider_params` has different structure depends on the provider. Here they
  already configured for **Telegram** provider.
  """
  def bot_configuration do
    %Agala.BotParams{
      name: "<%= app_module %>",
      provider: Agala.Provider.Telegram,
      handler: <%= app_module %>.EchoHandler,
      provider_params: %{
        token: "% Add your token here. You can change this code to get token from config or environment. %",
        poll_timeout: :infinity
      }
    }
  end
end
