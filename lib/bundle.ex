defmodule Agala.Bundle do
  @doc """
  Params:

  provider: Provider
  type: :plug | :poller

  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts], location: :keep do
      config = Agala.Config.compile_config(:bundler, __MODULE__, opts)
      @config config

      def start_app(app_spec) do
        case Agala.AppSpec.valid?(app_spec) do
          false ->
            {:error,
             %ArgumentError{
               message:
                 "app_spec:\n#{inspect(app_spec)}\n\nis invalid. Please, check it's specification"
             }}

          true ->
            case @config[:type] do
              :plug -> Agala.Bundle.Plug.start_app(app_spec, @config)
              :poller -> Agala.Bundle.Poller.start_app(app_spec, @config)
            end
        end
      end

      def which_apps() do
        case @config[:type] do
          :plug -> Agala.Bundle.Plug.which_apps(@config)
          :poller -> Agala.Bundle.Poller.which_apps(@config)
        end
      end

      def count_apps() do
        case @config[:type] do
          :plug -> Agala.Bundle.Plug.count_apps(@config)
          :poller -> Agala.Bundle.Poller.count_apps(@config)
        end
      end
    end
  end
end
