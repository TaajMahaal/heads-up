defmodule HeadsUpWeb.Api.IncidentJSON do
  def index(%{incidents: incidents}) do
    %{incidents: incidents}
  end

  def show(%{incident: incident}), do: incident
end
