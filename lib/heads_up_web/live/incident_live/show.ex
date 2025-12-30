defmodule HeadsUpWeb.IncidentLive.Show do
  use HeadsUpWeb, :live_view

  alias HeadsUp.Incidents
  alias Phoenix.LiveView.AsyncResult

  import HeadsUpWeb.CustomComponents
  import HeadsUpWeb.IncidentComponents

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    incident = Incidents.get_incident!(id)

    socket =
      socket
      |> assign(:incident, incident)
      |> assign(:page_title, incident.name)
      |> assign(:urgent_incidents, AsyncResult.loading())
      |> start_async(:fetch_urgent_incidents, fn ->
        Incidents.urgent_incidents(incident)
      end)

    {:noreply, socket}
  end

  def handle_async(:fetch_urgent_incidents, {:ok, incidents}, socket) do
    result = AsyncResult.ok(socket.assigns.urgent_incidents, incidents)

    {:noreply, assign(socket, :urgent_incidents, result)}
  end

  def handle_async(:fetch_urgent_incidents, {:exit, {exception, _stacktrace}}, socket) do
    message = Exception.message(exception)
    result = AsyncResult.failed(socket.assigns.urgent_incidents, {:error, message})

    {:noreply, assign(socket, :urgent_incidents, result)}
  end
end
