defmodule HeadsUpWeb.IncidentLive.Index do
  use HeadsUpWeb, :live_view

  import HeadsUpWeb.IncidentComponents
  alias HeadsUp.Incidents

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Incidents")
      |> assign(:resolved_count, Incidents.count_by_status(:resolved))
      |> assign(:form, to_form(%{}))
      |> stream(:incidents, Incidents.list_incidents())

    {:ok, socket}
  end

  def handle_event("filter", params, socket) do
    socket =
      socket
      |> assign(:form, to_form(params))
      |> stream(:incidents, Incidents.fitler_incidents(params), reset: true)

    {:noreply, socket}
  end
end
