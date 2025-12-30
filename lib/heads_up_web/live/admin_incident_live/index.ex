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
end
