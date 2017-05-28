defmodule Agala.Bot.Broadcast do
  defmacro __using__(_) do
    quote location: :keep do
      @doc """
      This function broadcast the message to your router.
      
      ## Args:

      * `message` - message, that would be broadcasting to
       your router from your hook. You can define the form
       of your messages, so they can be proceed by your router
       and then by your handlers.

      ## Example

      ```elixir
      broadcast("The weather is 31 degrees Celsies")
      ```
      """
      @spec broadcast(any) :: :ok
      def broadcast(message) do
        message
        |> Agala.get_router().route
      end
    end
  end
end