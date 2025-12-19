defmodule HeadsUp.Incidents do
  alias HeadsUp.Incidents.Incident
  alias HeadsUp.Repo

  import Ecto.Query, warn: false

  def list_incidents do
    Repo.all(Incident)
  end

  def get_incident!(id) do
    Repo.get!(Incident, id)
  end

  def urgent_incidents(incident) do
    Incident
    |> where([i], i.id != ^incident.id)
    |> order_by([i], desc: i.inserted_at)
    |> limit(5)
    |> Repo.all()
  end

  def count_by_status(status) do
    Incident
    |> where([i], i.status == ^status)
    |> Repo.aggregate(:count)
  end
end
