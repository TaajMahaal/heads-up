defmodule HeadsUpWeb.AdminIncidentLive.Form do
  use HeadsUpWeb, :live_view

  alias HeadsUp.Admin
  alias HeadsUp.Incidents.Incident

  def mount(_params, _session, socket) do
    changeset = Incident.changeset(%Incident{}, %{})

    socket =
      socket
      |> assign(:page_title, "New Incident")
      |> assign(:form, to_form(changeset))

    {:ok, socket}
  end

  def handle_event("save", %{"incident" => incident_params}, socket) do
    case Admin.create_incident(incident_params) do
      {:ok, incident} ->
        socket =
          socket
          |> put_flash(:info, "Incident created successfully")
          |> push_navigate(to: ~p"/admin/incidents")

      {:error, %Ecto.Changeset{} = changeset} ->
        socket =
          socket
          |> assign(:form, to_form(changeset))

        {:noreply, socket}
    end
  end
end
