defmodule HeadsUp.Incidents do
  alias HeadsUp.Categories.Category
  alias HeadsUp.Incidents.Incident
  alias HeadsUp.Repo

  import Ecto.Query, warn: false

  def get_incident!(id, preloads \\ []) do
    Repo.get!(Incident, id)
    |> Repo.preload(preloads)
  end

  def list_incidents do
    Incident
    |> Repo.all()
  end

  def count_by_status(status) do
    Incident
    |> where([i], i.status == ^status)
    |> Repo.aggregate(:count)
  end

  def urgent_incidents(incident) do
    Incident
    |> where([i], i.id != ^incident.id)
    |> where([i], i.status == :pending)
    |> order_by([i], desc: i.priority, asc: i.inserted_at)
    |> limit(5)
    |> Repo.all()
  end

  def filter_incidents(filter) do
    Incident
    |> with_status(filter["status"])
    |> with_category(filter["category"])
    |> search_by(filter["q"])
    |> sort(filter["sort_by"])
    |> preload(:category)
    |> Repo.all()
  end

  defp with_status(query, status) when status in ~w"pending resolved canceled" do
    where(query, status: ^status)
  end

  defp with_status(query, _), do: query

  defp search_by(query, q) when q in ["", nil], do: query

  defp search_by(query, q) do
    where(query, [i], ilike(i.name, ^"%#{q}%"))
  end

  defp with_category(query, slug) when slug in ["", nil], do: query

  defp with_category(query, slug) do
    from i in query,
      join: c in assoc(i, :category),
      where: c.slug == ^slug
  end

  defp sort(query, "priority_asc") do
    order_by(query, desc: :priority)
  end

  defp sort(query, "priority_desc") do
    order_by(query, asc: :priority)
  end

  defp sort(query, "status") do
    order_by(query, :status)
  end

  defp sort(query, "category") do
    from i in query,
      join: c in assoc(i, :category),
      order_by: c.name
  end

  defp sort(query, _) do
    order_by(query, :id)
  end
end
