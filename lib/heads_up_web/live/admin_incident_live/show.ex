defmodule HeadsUpWeb.AdminIncidentLive.Show do
  use HeadsUpWeb, :live_view

  alias HeadsUp.Incidents

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    incident = Incidents.get_incident!(id)

    socket =
      socket
      |> assign(:incident, incident)
      |> assign(:page_title, incident.name)

    {:noreply, socket}
  end
end
