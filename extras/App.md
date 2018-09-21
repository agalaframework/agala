# Agala.App

defmodule MyApp.Facebook do
  use Agala.App, [
      provider: Agala.Provider.Facebook,
      type: :plug,
      name: "facebook"
  ]

  def init() do
    
  end
end

# Agala.Bundle

```elixir
defmodule MyApp.Facebook do
  use Agala.Bundle, [
    provider: Agala.Provider.Facebook,
    type: :plug
  ]
end
```


Then in code:

```
MyApp.Facebook.count_apps()
MyApp.Facebook.start_app(app_spec)
MyApp.Facebook.delete_app(name)
MyApp.Facebook.restart_app(name)
MyApp.Facebook.terminate_app(name)
MyApp.Facebook.which_apps()

App Spec

%{
  name: "AcmeGroup",
  chain: AcmeChain,
  app_params: %{
    token: "enQ:33",
    ..
  }
}
```