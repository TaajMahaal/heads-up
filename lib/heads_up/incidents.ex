defmodule HeadsUp.Incidents do
  alias HeadsUp.Incidents.Incident
  alias HeadsUp.Repo

  import Ecto.Query, warn: false

  def list_incidents do
    Incident
    |> Repo.all()
  end

  # def fitler_incidents(%{"q" => q, "status" => status, "sort_by" => sort_by}) do
  def fitler_incidents(filter) do
    Incident
    |> with_status(filter["status"])
    |> search_by(filter["q"])
    |> sort(filter["sort_by"])
    |> Repo.all()
  end

  defp with_status(query, status) when status in ~w"pending resolved canceled" do
    where(query, status: ^status)
  end

  defp with_status(query, _), do: query

  defp search_by(query, q) when q not in ["", nil] do
    where(query, [i], ilike(i.name, ^"%#{q}%"))
  end

  defp search_by(query, _), do: query

  defp sort(query, "priority_asc") do
    order_by(query, desc: :priority)
  end

  defp sort(query, "priority_desc") do
    order_by(query, asc: :priority)
  end

  defp sort(query, "status") do
    order_by(query, :status)
  end

  defp sort(query, _) do
    order_by(query, :id)
  end

  def get_incident!(id) do
    Repo.get!(Incident, id)
  end

  def urgent_incidents(incident) do
    Incident
    |> where([i], i.id != ^incident.id)
    |> where([i], i.status == :pending)
    |> order_by([i], desc: i.priority, asc: i.inserted_at)
    |> limit(5)
    |> Repo.all()
  end

  def count_by_status(status) do
    Incident
    |> where([i], i.status == ^status)
    |> Repo.aggregate(:count)
  end
end
