defmodule HeadsUpWeb.IncidentLive.Index do
  use HeadsUpWeb, :live_view

  import HeadsUpWeb.IncidentComponents

  alias HeadsUp.Categories
  alias HeadsUp.Incidents

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Incidents")
      |> assign(:resolved_count, Incidents.count_by_status(:resolved))
      |> assign(:category_options, Categories.category_names_and_slugs())

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    socket =
      socket
      |> assign(:form, to_form(params))
      |> stream(:incidents, Incidents.filter_incidents(params), reset: true)

    {:noreply, socket}
  end

  def handle_event("filter", params, socket) do
    params =
      params
      |> Map.take(~w"q status category sort_by")
      |> Map.reject(fn {_, v} -> v == "" end)

    socket = push_patch(socket, to: ~p"/incidents?#{params}")

    {:noreply, socket}
  end
end
