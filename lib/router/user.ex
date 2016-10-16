defmodule Agala.Router.User do
  use Supervisor
  require Logger

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: Agala.Router.User)
  end

  def init(_) do
    children = [
      worker(Agala.get_handler(), [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end


  def route(message) do
    room_name = message |> start_chat
    Logger.debug("Routing message to room #{inspect room_name}")
    Agala.get_handler().handle_message(room_name, message)
  end

  def start_chat(message) do
    room_name = users_atom(message)
    Supervisor.start_child(Agala.Router.User, [room_name])
    room_name
  end

  defp users_atom(%{"message" => %{"chat" => %{"id" => user_id}}}) do
    user_id #|> Integer.to_string |> String.to_atom
  end
end

