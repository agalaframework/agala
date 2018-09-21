defmodule Agala.Config do
  def compile_config(:bundle, module, opts) do
    merge_with_app_config(module, opts)
    |> validate_config([:provider, :type])
  end

  defp merge_with_app_config(module, opts) do
    # :otp_app parameter is not mandatory. If it's not set - application configuration is ommited
    case Keyword.get(opts, :otp_app) do
      nil ->
        opts

      otp_app ->
        Keyword.merge(opts, Application.get_env(otp_app, module, []))
    end
    |> Enum.into(%{})
    |> Map.put(:module, module)
  end

  defp validate_config(config, keys) do
    Enum.each(keys, &validate_option(config, &1))
  end

  defp validate_option(config, :provider) do
    provider = config[:provider]

    unless provider do
      raise ArgumentError,
            "missing :provider configuration in #{inspect(config[:module])}. Check your use statement"
    end

    unless Code.ensure_compiled?(provider) do
      raise ArgumentError,
            "provider #{inspect(provider)} was not compiled, " <>
              "ensure it is correct and it is included as a project dependency"
    end

    unless Agala.Provider in Agala.Util.behaviours_list(provider) do
      raise ArgumentError,
            "provider #{inspect(provider)} does not implement Agala.Provider behaviour, " <>
              "ensure it is correct and it is included as a module in the project"
    end
  end

  defp validate_option(config, :type) do
    type = config[:type]

    unless type do
      raise ArgumentError,
            "missing :type configuration in #{inspect(config[:module])}. Check your use statement"
    end

    unless type in [:plug, :poller] do
      raise ArgumentError,
            ":type configuration should be :poller or :plug. Check your configuration"
    end
  end

  defp validate_option(config, :name) do
    name = config[:name]

    unless name do
      raise ArgumentError,
            "missing :name configuration in #{inspect(config[:module])}. Check your use statement"
    end
  end
end
