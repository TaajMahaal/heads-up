defmodule HeadsUpWeb.AdminIncidentLive.Index do
  use HeadsUpWeb, :live_view

  alias HeadsUp.Admin

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Listing incidents")
      |> stream(:incidents, Admin.list_incidents(:category))

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

  def toggle_joke(js \\ %JS{}) do
    js
    |> JS.toggle(to: "#joke", in: "fade-in-scale", out: "fade-out-scale")
    |> JS.toggle_attribute({"aria-expanded", "true", "false"})
  end

  def click_delete(js \\ %JS{}, dom_id, incident) do
    js
    |> JS.push("delete", value: %{id: incident.id})
    |> JS.hide(to: "##{dom_id}", transition: "fade-out duration-300")
  end
end
