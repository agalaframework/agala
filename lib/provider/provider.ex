defmodule Agala.Provider do
  @moduledoc """
  Behaviour that defines root structure for Agala provider
  """

  @doc """
  This function defines name for `Agala.Reciever` module for specific provider.
  This adds some portion of flexibility for provider creators - the are not forced
  to follow any naming convention.

  ## Examples

      iex> Agala.Provider.Vk.get_receiver
      Agala.Provider.Vk.Receiver
      iex> Agala.Provider.Telegram.get_receiver
      Agala.Provider.Telegram.Receiver
  """
  @callback get_bot(:poller | :plug | :handler) :: atom

  @typedoc """
  Provider is represented by it's module name
  """
  @type t :: atom()

  defmacro __using__(_opts) do
    quote location: :keep do
      @behaviour Agala.Provider

      def get_bot(:poller) do
        Module.concat(__MODULE__, Poller)
      end

      def get_bot(:plug) do
        Module.concat(__MODULE__, Plug)
      end

      def get_bot(:handler) do
        Module.concat(__MODULE__, Handler)
      end

      defoverridable get_bot: 1
    end
  end
end
