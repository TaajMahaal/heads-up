defmodule HeadsUpWeb.IncidentLive.Index do
  use HeadsUpWeb, :live_view

  import HeadsUpWeb.IncidentComponents
  alias HeadsUp.Incidents

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Incidents")
      |> assign(:resolved_count, Incidents.count_by_status(:resolved))
      |> stream(:incidents, Incidents.list_incidents())

    {:ok, socket}
  end
end
