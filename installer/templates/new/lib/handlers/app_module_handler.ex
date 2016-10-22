defmodule <%= app_module %>.Handler do
  use Agala.Handler

  # Implement Agala.Handler behaviour

  # Function defines handler's initial state
  def state do
    []
  end

  # Function defines main loop function for handling incoming messages
  def handle(state, message) do
    # Do something with message

    # Return new state 
    state
  end
end

