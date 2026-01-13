defmodule HeadsUpWeb.IncidentLive.Show do
  use HeadsUpWeb, :live_view

  alias HeadsUp.Incidents
  alias HeadsUp.Responses
  alias HeadsUp.Responses.Response
  alias Phoenix.LiveView.AsyncResult

  import HeadsUpWeb.IncidentComponents
  import HeadsUpWeb.CustomComponents

  on_mount {HeadsUpWeb.UserAuth, :mount_current_user}

  def mount(_params, _session, socket) do
    changeset = Responses.change_response(%Response{})

    socket =
      socket
      |> assign(:form, to_form(changeset))
      |> stream(:responses, [])

    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    incident = Incidents.get_incident!(id, [:category])

    socket =
      socket
      |> assign(:incident, incident)
      |> assign(:page_title, incident.name)
      |> assign(:responses_loading, true)
      |> assign(:urgent_incidents, AsyncResult.loading())
      |> start_async(:fetch_responses, fn ->
        Responses.list_responses_by_incident_id(id)
      end)
      |> start_async(:fetch_urgent_incidents, fn ->
        Incidents.urgent_incidents(incident)
      end)

    {:noreply, socket}
  end

  def handle_async(:fetch_urgent_incidents, {:ok, incidents}, socket) do
    result = AsyncResult.ok(socket.assigns.urgent_incidents, incidents)

    {:noreply, assign(socket, :urgent_incidents, result)}
  end

  def handle_async(:fetch_urgent_incidents, {:exit, reason}, socket) do
    result = AsyncResult.failed(socket.assigns.urgent_incidents, {:error, reason})

    {:noreply, assign(socket, :urgent_incidents, result)}
  end

  def handle_async(:fetch_responses, {:ok, responses}, socket) do
    socket =
      socket
      |> stream(:responses, responses)
      |> assign(:responses_loading, false)

    {:noreply, socket}
  end

  def handle_async(:fetch_responses, {:exit, _reason}, socket) do
    {:noreply, assign(socket, :responses_loading, false)}
  end

  def handle_event("validate", %{"response" => response_params }, socket) do
    changeset = Responses.change_response(%Response{}, response_params)

    socket = assign(socket, :form, to_form(changeset, action: :validate))

    {:noreply, socket}
  end

  def handle_event("save", %{"response" => response_params }, socket) do
    %{incident: incident, current_user: user} = socket.assigns

    case Responses.create_response(incident, user, response_params) do
        {:ok, response} ->
          changeset = Responses.change_response(%Response{})

          socket =
            socket
            |> stream_insert(:responses, response, at: 0)
            |> assign(:form, to_form(changeset))

          {:noreply, socket}
        {:error, changeset} ->
          socket = assign(socket, :form, to_form(changeset))

          {:noreply, socket}
    end
  end
end
