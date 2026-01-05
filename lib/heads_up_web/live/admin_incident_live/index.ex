defmodule HeadsUpWeb.AdminIncidentLive.Index do
  use HeadsUpWeb, :live_view

  alias HeadsUp.Admin

  # import HeadsUpWeb.IncidentComponents

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Listing incidents")
      |> stream(:incidents, Admin.list_incidents())

    {:ok, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    incident = Admin.get_incident!(id)

    case Admin.delete_incident(incident) do
      {:ok, incident} ->
        socket =
          socket
          |> stream_delete(:incidents, incident)
          |> put_flash(:info, "Incident #{incident.name} deleted successfully")

        {:noreply, socket}

      _ ->
        socket =
          socket
          |> put_flash(:error, "Failed to delete incident #{incident.name}")

        {:noreply, socket}
    end
  end
end
