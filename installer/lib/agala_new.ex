defmodule Mix.Tasks.Agala.New do
  use Mix.Task
  import Mix.Generator

  @agala Path.expand("../..", __DIR__)
  @version Mix.Project.config[:version]
  @shortdoc "Creates a new Agala v#{@version} application"

  # File mappings

  @new [
    # Config
    {:eex, "new/config/config.exs", "config/config.exs"},
    {:eex, "new/config/dev.exs", "config/dev.exs"},
    {:eex, "new/config/prod.exs", "config/prod.exs"},
    {:eex, "new/config/test.exs", "config/test.exs"},

    # Lib
    {:eex, "new/lib/app_name.ex", "lib/app_name.ex"},
    {:eex, "new/lib/handlers/app_module_handler.ex", "lib/handlers/app_module_handler.ex"},
    {:keep, "new/lib/routers", "lib/routers"},

    # Mix
    {:eex, "new/mix.exs", "mix.exs"},
    {:eex, "new/README.md", "README.md"}
  ]

  # Embed all defined templates
  root = Path.expand("../templates", __DIR__)

  for {format, source, _} <- @new do
    unless format == :keep do
      @external_resource Path.join(root, source)
      def render(unquote(source)), do: unquote(File.read!(Path.join(root, source)))
    end
  end

  @moduledoc """
  Creates a new Agala project.

  It expects the path of the project as argument.

  mix agala.new PATH [--module MODULE] [--app APP]

  A project at the given PATH will be created. The
  application name and module name will be retrieved
  from the path, unless `--module` or `--app` is given.

  ## Options
  * `--app` - the name of the OTP application
  * `--module` - the name of the base module in
  the generated skeleton

  ## Examples
  mix agala.new hello_bot
  Is equivalent to:
  mix agala.new hello_bot --module HelloBot

  """

  @switches [app: :string, module: :string]

  def run([version]) when version in ~w(-v --version) do
     Mix.shell.info "Agala v#{@version}"
  end

  def run(argv) do
    unless Version.match?(System.version, "~> 1.3") do
      Mix.raise "Agala v#{@version} requires at least Elixir v1.3.\n"<>
      "You have #{System.version}. Please update accordingly"
    end

    {opts, argv} = 
      case OptionParser.parse(argv, strict: @switches) do
        {opts, argv, []} ->
          {opts, argv}
        {_opts, _argv, [switch | _]} ->
          Mix.raise "Invalid option: " <> switch_to_string(switch)
      end

      case argv do
        [] ->
          Mix.Tasks.Help.run ["agala.new"]
        [path|_] ->
          app = opts[:app] || Path.basename(Path.expand(path))
          check_application_name!(app, !!opts[:app])
          check_directory_existence!(app)
          mod = opts[:module] || Macro.camelize(app)
          check_module_name_validity!(mod)
          check_module_name_availability!(mod)
          run(app, mod, path, opts)
      end
  end

  def run(app, mod, path, opts) do
    agala_path = agala_path(path, Keyword.get(opts, :dev, false))

    in_umbrella? = in_umbrella?(path)

    binding = 
      [ 
        app_name: app,
        app_module: mod,
        agala_dep: agala_dep(agala_path),
        agala_path: agala_path,
        in_umbrella: in_umbrella?,
        hex?: Code.ensure_loaded?(Hex),
        namespaced?: Macro.camelize(app) != mod
      ]

      copy_from path, binding, @new

      install? = Mix.shell.yes?("\nFetch and install dependencies?")

      File.cd!(path, fn ->
        mix? = install_mix(install?)
        extra = if mix?, do: [], else: ["$ mix deps.get"]

          print_mix_info(path, extra)
      end)
  end

  defp switch_to_string({name, nil}), do: name
  defp switch_to_string({name, val}), do: name <> "=" <> val

  defp install_mix(install?) do
    maybe_cmd "mix deps.get", true, install? && Code.ensure_loaded?(Hex)
  end

  defp print_mix_info(path, extra) do
    steps = ["$ cd #{path}"] ++ extra ++ ["$ mix agala.server"]

    Mix.shell.info """
    We are all set! Run your Agala application:
    #{Enum.join(steps, "\n    ")}
    You can also run your app inside IEx (Interactive Elixir) as:
      $ iex -S mix agala.server
      """
  end

    # Helpers

  defp maybe_cmd(cmd, should_run?, can_run?) do
    cond do
      should_run? && can_run? ->
        cmd(cmd)
      true
      should_run? ->
        false
      true ->
        true
    end
  end

  defp cmd(cmd) do
    Mix.shell.info [:green, "* running ", :reset, cmd]
    case Mix.shell.cmd(cmd, [quiet: true]) do
      0 ->
        true
      _ ->
        Mix.shell.error [:red, "* error ", :reset, "command failed to execute, " <>
       "please run the following command again after installation: \"#{cmd}\""]
  false
    end
  end

  defp check_application_name!(name, from_app_flag) do
    unless name =~ ~r/^[a-z][\w_]*$/ do
      extra =
        if !from_app_flag do
          ". The application name is inferred from the path, if you'd like to " <>
          "explicitly name the application then use the `--app APP` option."
        else
          ""
        end

        Mix.raise "Application name must start with a letter and have only lowercase " <>
        "letters, numbers and underscore, got: #{inspect name}" <> extra
    end
  end

  defp check_module_name_validity!(name) do
    unless name =~ ~r/^[A-Z]\w*(\.[A-Z]\w*)*$/ do
      Mix.raise "Module name must be a valid Elixir alias (for example: Foo.Bar), got: #{inspect name}"
    end
  end

  defp check_module_name_availability!(name) do
    name = Module.concat(Elixir, name)
    if Code.ensure_loaded?(name) do
      Mix.raise "Module name #{inspect name} is already taken, please choose another name"
    end
  end

  defp check_directory_existence!(name) do
    if File.dir?(name) and not Mix.shell.yes?("The directory #{name} already exists. Are you sure you want to continue?") do
                   Mix.raise "Please select another directory for installation."
    end
  end

  defp kw_to_config(kw) do
    Enum.map(kw, fn {k, v} ->
      ",\n  #{k}: #{inspect v}"
    end)
  end

  defp in_umbrella?(app_path) do
    try do
      umbrella = Path.expand(Path.join [app_path, "..", ".."])
      File.exists?(Path.join(umbrella, "mix.exs")) &&
                   Mix.Project.in_project(:umbrella_check, umbrella, fn _ ->
                     path = Mix.Project.config[:apps_path]
                     path && Path.expand(path) == Path.join(umbrella, "apps")
                   end)
    catch
      _, _ -> false
    end
  end

  defp agala_dep("deps/agala"), do: ~s[{:agala, "~> #{@version}"}]
  defp agala_dep(path), do: ~s[{:agala, path: #{inspect path}, override: true}]

  defp agala_static_path("deps/agala"), do: "deps/agala"
  defp agala_static_path(path), do: Path.join("..", path)
  
  defp agala_path(path, true) do
    absolute = Path.expand(path)
    relative = Path.relative_to(absolute, @agala)

    if absolute == relative do
      Mix.raise "--dev projects must be generated inside Agala directory"
    end

    relative
    |> Path.split
    |> Enum.map(fn _ -> ".." end)
    |> Path.join
  end

  defp agala_path(_path, false), do: "deps/agala"

  ## Template helpers

  defp copy_from(target_dir, binding, mapping) when is_list(mapping) do
    app = Keyword.fetch!(binding, :app_name)
    module = Keyword.fetch!(binding, :app_module)
    for {format, source, target_path} <- mapping do
      target_path = target_path
      |> String.replace("app_name", app)
      |> String.replace("app_module", Macro.underscore(module))
      target = Path.join(target_dir, target_path)
      case format do
        :keep ->
          File.mkdir_p!(target)
        :text ->
          create_file(target, render(source))
        :append ->
          append_to(Path.dirname(target), Path.basename(target), render(source))
        :eex  ->
          contents = EEx.eval_string(render(source), binding, file: source)
          create_file(target, contents)
      end
    end
  end

  defp append_to(path, file, contents) do
    file = Path.join(path, file)
    File.write!(file, File.read!(file) <> contents)
  end

end
