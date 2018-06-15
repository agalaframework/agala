## General configuration

General `Agala` workflow has and idea of creating custome modules, that that 
are injected all functionality by **__using__** macro.

You can create:
* **`Agala.Bot`** - 





### Bot configuration

```
defmodule MyApp.TelegramBot do
  use Agala.Bot.Poller, otp_app: :my_app

  def init(_type, config) do
    {:ok, Keyword.put(config, :provider, )
  end
end
```