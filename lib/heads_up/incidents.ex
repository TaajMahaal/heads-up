defmodule HeadsUp.Incidents do
  alias HeadsUp.Incidents.Incident
  alias HeadsUp.Repo

  import Ecto.Query, warn: false

  def list_incidents do
    Incident
    |> Repo.all()
  end

  # def fitler_incidents(%{"q" => q, "status" => status, "sort_by" => sort_by}) do
  def fitler_incidents(%{}) do
    Incident
    |> Repo.all()
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
