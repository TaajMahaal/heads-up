defmodule HeadsUpWeb.IncidentLive.Show do
  use HeadsUpWeb, :live_view

  alias HeadsUp.Incidents

  import HeadsUpWeb.CustomComponents
  import HeadsUpWeb.IncidentComponents

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    incident = Incidents.get_incident(id)
    urgent_incidents = Incidents.urgent_incidents(incident)

    socket =
      socket
      |> assign(:incident, incident)
      |> assign(:page_title, incident.name)
      |> assign(:urgent_incidents, urgent_incidents)

    {:noreply, socket}
  end
end
