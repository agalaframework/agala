defmodule Agala.Bot.Supervisor do

  @doc """
  Retrieves the compile time configuration for the bot.
  """
  def compile_config(bot, opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)
    config  = Application.get_env(otp_app, bot, [])

    # Provider checking section

    provider = opts[:provider] || config[:provider]

    unless provider do
      raise ArgumentError, "missing :provider configuration in " <>
                           "config #{inspect otp_app}, #{inspect bot}"
    end

    unless Code.ensure_loaded?(provider) do
      raise ArgumentError, "provider #{inspect provider} was not compiled, " <>
                           "ensure it is correct and it is included as a project dependency"
    end

    # Handler checking section

    handler = opts[:handler] || config[:handler]

    unless handler do
      raise ArgumentError, "missing :handler configuration in " <>
                           "config #{inspect otp_app}, #{inspect bot}"
    end

    unless Code.ensure_loaded?(handler) do
      raise ArgumentError, "handler #{inspect handler} was not compiled, " <>
                           "ensure it is correct and it is included as a module in the project"
    end

    unless [Agala.Handler] == get_in(handler.module_info, [:attributes, :behaviour]) do
      raise ArgumentError, "handler #{inspect handler} does not implement Agala.Handler behaviour, " <>
                           "ensure it is correct and it is included as a module in the project"
    end

    {otp_app, provider, config}
  end
end
