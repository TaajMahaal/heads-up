defmodule HeadsUp.Admin do
  alias HeadsUp.Incidents
  alias HeadsUp.Incidents.Incident
  alias HeadsUp.Repo

  import Ecto.Query, warn: false

  def get_incident!(id, preloads \\ []) do
    Repo.get!(Incident, id)
    |> Repo.preload(preloads)
  end

  def list_incidents(preloads \\ []) do
    Incident
    |> order_by(desc: :inserted_at)
    |> preload(^preloads)
    |> Repo.all()
  end

  def create_incident(attrs \\ %{}) do
    %Incident{}
    |> Incident.changeset(attrs)
    |> Repo.insert()
  end

  def change_incident(%Incident{} = incident, attrs \\ %{}) do
    Incident.changeset(incident, attrs)
  end

  def update_incident(%Incident{} = incident, attrs) do
    incident
    |> Incident.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, incident} ->
        incident = Repo.preload(incident, :category)

        Incidents.broadcast(incident.id, {:incident_updated, incident})
        {:ok, incident}

      {:error, _} = error ->
        error
    end
  end

  def delete_incident(incident) do
    Repo.delete(incident)
  end
end
