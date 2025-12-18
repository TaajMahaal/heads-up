defmodule HeadsUpWeb.IncidentLive.Index do
  import HeadsUpWeb.IncidentComponents

  use HeadsUpWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     assign(
       socket,
       incidents: HeadsUp.Incidents.list_incidents(),
       page_title: "Incidents"
     )}
  end
end
