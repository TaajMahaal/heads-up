defmodule HeadsUpWeb.Api.CategoryJSON do
  alias HeadsUpWeb.Api.IncidentJSON

  def index(%{categories: categories}) do
    %{
      categories:
        for(
          category <- categories,
          do: data(category)
        )
    }
  end

  def show(%{category: category}), do: data(category)

  defp data(category) do
    category
    |> base_data()
    |> maybe_include_incidents(category.incidents)
  end

  defp base_data(category) do
    %{
      id: category.id,
      name: category.name,
      slug: category.slug
    }
  end

  defp maybe_include_incidents(category_json, incidents) when is_list(incidents) do
    %{:incidents => incidents_json} = IncidentJSON.index(%{incidents: incidents})
    Map.put(category_json, :incidents, incidents_json)
  end

  defp maybe_include_incidents(category_json, _), do: category_json
end
