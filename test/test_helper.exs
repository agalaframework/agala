for app <- Application.spec(:agala,:applications) do
  Application.ensure_all_started(app)
end

ExUnit.start()
