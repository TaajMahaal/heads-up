defmodule HeadsUpWeb.IncidentLive.Index do
  use HeadsUpWeb, :live_view

  import HeadsUpWeb.IncidentComponents
  alias HeadsUp.Incidents

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    socket =
      socket
      |> assign(:page_title, "Incidents")
      |> assign(:resolved_count, Incidents.count_by_status(:resolved))
      |> assign(:form, to_form(params))
      |> stream(:incidents, Incidents.filter_incidents(params))

    {:noreply, socket}
  end

  def handle_event("filter", params, socket) do
    params =
      params
      |> Map.take(~w"q status sort_by")
      |> Map.reject(fn {_, v} -> v == "" end)

    socket = push_navigate(socket, to: ~p"/incidents?#{params}")

    {:noreply, socket}
  end
end
