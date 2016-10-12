defmodule Agala.Router.Direct do
  use Supervisor

  @default_handler Agala.Handler.Echo

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: Agala.Router.Direct)
  end

  def init(_) do
    children = [
      worker(Agala.get_handler(), [Agala.get_handler()])
    ]

    supervise(children, strategy: :one_for_one)
  end


  def route(message) do
    Agala.get_handler().handle_message(Agala.get_handler(), message)
  end

end

