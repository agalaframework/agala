defmodule Agala.Bundle.Plug do
  def start_app(app_spec, config) do
    module = config[:module]
    name = app_spec[:name]
    apps = SwarmGlobal.get(module, %{})

    case apps[name] do
      {:started, _} ->
        {:error, :already_started}

      {:stopped, _} ->
        {:error, :already_started}

      nil ->
        updated_apps =
          apps
          |> Map.put(name, {:started, app_spec})

        SwarmGlobal.put(module, updated_apps)
    end
  end

  def which_apps(config) do
    SwarmGlobal.get(config[:module], %{})
  end

  def count_apps(config) do
    specs = which_apps(config)

    [:specs, :started, :stopped]
    |> Enum.reduce(%{}, &Map.put(&2, &1, count_apps(&1, specs)))
  end

  defp count_apps(:specs, specs) do
    Enum.count(specs)
  end

  defp count_apps(:started, specs) do
    specs
    |> Enum.filter(fn
      {:started, _} -> true
      _ -> false
    end)
    |> Enum.count()
  end

  defp count_apps(:stopped, specs) do
    specs
    |> Enum.filter(fn
      {:stopped, _} -> true
      _ -> false
    end)
    |> Enum.count()
  end
end
