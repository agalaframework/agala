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
  @callback get_receiver() :: atom

  @doc """
  This function defines name for `Agala.Responser` module for specific provider.
  This adds some portion of flexibility for provider creators - the are not forced
  to follow any naming convention.

  ## Examples

      iex> Agala.Provider.Vk.get_responser
      Agala.Provider.Vk.Responser
      iex> Agala.Provider.Telegram.get_responser
      Agala.Provider.Telegram.Responser
  """
  @callback get_responser() :: atom

  @typedoc """
  Provider is represented by it's module name
  """
  @type t :: atom()

  defmacro __using__(_opts) do
    quote location: :keep do
      @behaviour Agala.Provider

      def get_receiver do
        Module.concat(__MODULE__, Receiver)
      end

      def get_responser do
        Module.concat(__MODULE__, Responser)
      end

      defoverridable [get_receiver: 0, get_responser: 0]
    end
  end
end
