# Agala [![Hex.pm](https://img.shields.io/hexpm/v/agala.svg)](https://hex.pm/packages/agala) [![Travis](https://img.shields.io/travis/Virviil/agala.svg)](https://travis-ci.org/Virviil/agala) [![Deps Status](https://beta.hexfaktor.org/badge/all/github/Virviil/agala.svg)](https://beta.hexfaktor.org/github/Virviil/agala) [![Coverage](http://inch-ci.org/github/virviil/agala.svg)(http://inch-ci.org/github/virviil/agala)

Full-featured Telegram bot framework.

## Installation via Mix

You can scaffold your new bot with simple commands! To do this:

  1. Install archive to your local Mix:

    ```bash
    $ mix archive.install
    https://github.com/Virviil/agala/releases/download/v1.0.1/agala_new-1.0.1.ez
    ```
  2. Simply run
    
    ```bash
    $ mix agala.new
    ```

    to see next instructions.

## Installation via Hex

The package is [available in Hex](https://hex.pm/packages/agala), and can be installed as:

  1. Add `agala` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:agala, "~> 1.0.1"}]
    end
    ```

  2. Ensure `agala` is started before your application:

    ```elixir
    def application do
      [applications: [:agala]]
    end
    ```

## Configuration

The full configuration looks like this:

```elixir
config :agala,
  token_env: "TELEGRAM_TOKEN",
  request_timeout: 100,
  router: MyApp.SuperRouter,
  handler: MyApp.SuperHandler.
```

Meanwhile, almost all parameters are optional, and will be discussed in next sections

### :token_env

In order to have better deplopoyment experience, you **Telegram bot token**, which should be obtained from [BotFather](https://telegram.me/BotFather),
should be exported to the environment with name, maped to `:token_env` parameter. For example, if
in your configuration you use 

```elixir
  token_env: "TELEGRAM_TOKEN"
```

then you should export your token with the same name like this:

```bash
export TELEGRAM_TOKEN="123...xyz"
```

**This parameter is optional. By default, token name is `"TELEGRAM_TOKEN"`**

### :request_timeout

This parameter specifies timeout for requests to **Telegram API**. The bigger it is, the more likely request would pass with bad Internet connection. Meanwhile, your bot response speed could be decreased.

You should use integers, representing timeout in seconds.

```elixir
  request_timeout: 12345
```

**This parameter is optional. By default, timeout value is `1`**

### :router

This parameter represents name of the module, which is routing messages, incoming to your **bot** to handlers. You cant read in documentation, what router is doing additionaly, and even **how to implement your own router**.

But, for simple use cases, `Agala` comes with two configured routers: **Direct** and **User**. You can read about them in the next section.

To configure router, just map it's name to this parameter:

```elixir
  router: Agala.Router.User
```

**This parameter is optional. By default, router is `Agala.Router.Direct`**

### :handler

This parameter represents name of the module, which is handling messages, incoming from your **router**. 

This is the part of application, which should be implemented by **you**. To know, how to do this - read appropriate section.
**Agala** comes with simple **echo handler**, which just resends incoming message back. Obviosly you would never use it - it's done for test purposes.

To configure handler, just map it's name to this parameter:

```elixir
  handler: MyApp.MyHandler
```

**This parameter is optional. By default, router is `Agala.Handler.Echo`**

## Routers

Routers do the next things:

1. Routes incoming messages to **handlers**

2. Supervises handler processes tree

Agala comes with two routers: **Direct** and **User**

### Direct

**Direct** router creates single **handler** process and pass all incoming messages to it. It's the simplest case. It also supervises **handler** process: if it falls - router will ensure to restart it before passing new incomming messages.

To use this router, put in your configuration:

```elixir
  router: Agala.Router.Direct
```

or don't put anything, because this router goes by default.

### User

**User** router creates **handler** process for every unique user, which is writing message to bot. It also supervises all this **handler** processes: if one of them falls - router will ensure to restart it before passing new incoming message.

The main idea of using this router is that all incoming messages to the handler comes from one user. So you can simply make your handler **statefull**.

To use this router, put in your configuration:

```elixir
  router: Agala.Router.User
```

## Contributing

1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request
