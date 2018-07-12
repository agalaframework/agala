## Bots

**Bots** are main construction mechanism of **Agala** systems. You can define a **Bot**, 
start it inside your supervision tree or define it as a handler to your plugs, 
and all **API-connected** work will be done by itself.

## Long-polling receiving bots

Let's for example look at **Telegram** long-polling receiving bot.

It can be defined as custom module:

```elixir
defmodule MyApp.TelegramReceiver do
  use Agala.Bot.Poller, [
    otp_app: :my_app,
    provider: Agala.Provider.Telegram,
    chain: MyApp.TelegramChain,
    provider_params: %Agala.Provider.Telegram.Poller.Params{
      token: "%TOKEN%",
      ...
    }
  ]
end
```

## WebHooks receiving bots

Let's for example look at **Telegram** WebHooks receiving bot.

```elixir
defmodule MyApp.TelegramReceiver do
  use Agala.Bot.Plug, [
    otp_app: :my_app,
    provider: Agala.Provider.Telegram,
    chain: MyApp.TelegramChain,
    provider_params: %Agala.Provider.Telegram.Plug.Params{
      token: "%TOKEN%",
      ...
    }
  ]
end
```



## Backbone handler bots

```elixir
defmodule MyApp.TelegramHandler do
  use Agala.Bot.Handler, [
    id: MyApp.Telegram
    provider: Agala.Provider.Telegram,
    receiver: MyApp.TelegramReceiver,
    chain: MyApp.TelgramHandleChain,
    provider_params: %Agala.Provider.Telegram.Handler.Params{
      ...
    }
  ]
end
```

Rabbit:
"agala.Elixir.MyApp.Telegram.in"
"agala.Elixir.MyApp.Telegram.out"

Rabbit:

"agala.Elixir.MyApp.Telegram.rfc"

"agala.Elixir.MyApp.Telegram.rfc.139" "sendPhoto"



def handler(conn, _) do

  {:ok, xchtoto} = Telegram.get_name(id) :
    HTTPOSISOTN.get()

  {:ok, task} = Whatsapp.get_name(id, fn (response) -> end)
  {:ok, response} = Task.await(task)

  Task(
    AMQP.subscribe("agala.Elixir.MyApp.Telegram.rfc.139" "sendPhoto")
    recive do
      ok -> resp
  )


end



### Compilation checks

In order to provide the most fast response to something wrong in the configuration of the bot, 
some configuration params are checked during compilation time, and should be specified either
in `Mix.Config` configuration files, or inside keyword, passed as argument to `use Agala.Bot._type_`,
or inside `init/2` callback.

Thus, if you want to read these configuration from environment, using for example `System.get_env`,
these configurations should be specified inside your build environment.

Meanwhile, configuration is just **checked** during compilation, not **compiled inside the program**.
All configurations will be reread during `Agala.Bot` start process. So you can override 
it in your production environment.

**BUT!** Facing problems with bot configuration can be an indicator of a bad code. The best ideaa will
be to understand what is **runtime configuration** and what is **release configuration**,
and refactor the code in respect of this understanding.

Next variables are checked during compilation:

* `:otp_app` - main config variable, that can be specified only as argument of `__using__` statement.
  This variable will be used to match configuration, specified in `Mix.Config`, with concrete `Agala.Bot`
  implementation. Compilation will rise, if this variable is not specified or wrong.

* `:chain` - this variable specifies the pipeline to handle incoming events. It should be specified and
  implement `Agala.Chain` behaviour. In other case compilation will rise.

* `:provider` - this variable specifies provider for entire bot. Compilation will rise if bot is not specified,
  or it's implemented wrong.