defmodule HeadsUpWeb.AdminIncidentLive.Form do
  use HeadsUpWeb, :live_view

  alias HeadsUp.Admin

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "New Incident")
      |> assign(:form, to_form(%{}, as: "incident"))

    {:ok, socket}
  end

  def handle_event("save", %{"incident" => incident_params}, socket) do
    _incident = Admin.create_incident(incident_params)

    socket = push_navigate(socket, to: ~p"/admin/incidents")

    {:noreply, socket}
  end
end
