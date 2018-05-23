defmodule Agala.Backbone.RabbitMQ do
  @behaviour Agala.Backbone
  use Supervisor

  @moduledoc """
  This backbone lays on **RabbitMQ** brocker.

  # Configuration

  ## RabbitMQ connection

  Configure RabbitMQ connection using options, listed below:
    * `:username` - The name of a user registered with the broker (defaults to \"guest\");
    * `:password` - The password of user (defaults to \"guest\");
    * `:virtual_host` - The name of a virtual host in the broker (defaults to \"/\");
    * `:host` - The hostname of the broker (defaults to \"localhost\");
    * `:port` - The port the broker is listening on (defaults to `5672`);
    * `:channel_max` - The channel_max handshake parameter (defaults to `0`);
    * `:frame_max` - The frame_max handshake parameter (defaults to `0`);
    * `:heartbeat` - The hearbeat interval in seconds (defaults to `10`);
    * `:connection_timeout` - The connection timeout in milliseconds (defaults to `60000`);
    * `:ssl_options` - Enable SSL by setting the location to cert files (defaults to `none`);
    * `:client_properties` - A list of extra client properties to be sent to the server, defaults to `[]`;
    * `:socket_options` - Extra socket options. These are appended to the default options. \
                          See [http://www.erlang.org/doc/man/inet.html#setopts-2]() and [http://www.erlang.org/doc/man/gen_tcp.html#connect-4]() \
                          for descriptions of the available options.
  ### Enabling SSL
  To enable SSL, supply the following in the `ssl_options` field:
    * `cacertfile` - Specifies the certificates of the root Certificate Authorities that we wish to implicitly trust;
    * `certfile` - The client's own certificate in PEM format;
    * `keyfile` - The client's private key in PEM format;

  ## Agala Backbone configuration

  Use these options to add additional configuration to backbone:

    * `:domain` - Route prefix for RabbitMQ queues (defaults is \"agala\")
    * `:pool_size` - Size of connection's pool for the RabbitMQ server (default is 10)
  """

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: Agala.Backbone.RabbitMQ.Supervisor)
  end

  @impl Supervisor
  def init(_arg) do
    children = [
      :poolboy.child_spec(:worker, poolboy_config())
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp poolboy_config() do
    [
      name: {:local, Agala.Backbone.RabbitMQ.ConnectionPool},
      worker_module: Agala.Backbone.RabbitMQ.Connection,
      size: Agala.Backbone.RabbitMQ.Config.get_config(:pool_size),
      max_overflow: 0,
      strategy: :fifo
    ]
  end

  ### Configuration

  @impl Agala.Backbone
  defdelegate bake_backbone_config(), to: Agala.Backbone.RabbitMQ.Config

  @impl Agala.Backbone
  defdelegate get_config(), to: Agala.Backbone.RabbitMQ.Config

  ### Monitoring

  @impl Agala.Backbone
  defdelegate get_load(bot_name), to: Agala.Backbone.RabbitMQ.Monitor

  @impl Agala.Backbone
  defdelegate init_bot(bot_name), to: Agala.Backbone.RabbitMQ.Monitor

  ### Transfer

  @impl Agala.Backbone
  defdelegate push(bot_name, cid, value), to: Agala.Backbone.RabbitMQ.Transfer

  @impl Agala.Backbone
  defdelegate pull(bot_name), to: Agala.Backbone.RabbitMQ.Transfer

end
