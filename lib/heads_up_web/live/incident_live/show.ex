defmodule HeadsUpWeb.IncidentLive.Show do
  use HeadsUpWeb, :live_view

  alias HeadsUp.Incidents
  alias HeadsUp.Responses
  alias HeadsUp.Responses.Response
  alias Phoenix.LiveView.AsyncResult

  import HeadsUpWeb.CustomComponents
  import HeadsUpWeb.IncidentComponents
  alias HeadsUpWeb.Presence

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
    %{current_user: current_user} = socket.assigns

    if connected?(socket) do
      Incidents.subscribe(id)

      if current_user do
        {:ok, _} = Presence.track(self(), topic(id), current_user.username, %{
          online_at: System.system_time(:second)
        })
      end
    end

    presences =
      Presence.list(topic(id))
      |> Enum.map(fn {username, %{metas: metas}} ->
        %{id: username, metas: metas} end)

    incident = Incidents.get_incident!(id, [:category, heroic_response: :user])

    socket =
      socket
      |> assign(:incident, incident)
      |> assign(:page_title, incident.name)
      |> assign(:responses_loading, true)
      |> stream(:presences, presences)
      |> assign(:urgent_incidents, AsyncResult.loading())
      |> start_async(:fetch_responses, fn ->
        Incidents.list_responses(incident)
      end)
      |> start_async(:fetch_urgent_incidents, fn ->
        Incidents.urgent_incidents(incident)
      end)

    {:noreply, socket}
  end

  defp topic(id) do
    "incident_watchers:#{id}"
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
      |> assign(:response_count, Enum.count(responses))
      |> assign(:responses_loading, false)

    {:noreply, socket}
  end

  def handle_async(:fetch_responses, {:exit, _reason}, socket) do
    {:noreply, assign(socket, :responses_loading, false)}
  end

  def handle_event("validate", %{"response" => response_params}, socket) do
    changeset = Responses.change_response(%Response{}, response_params)

    socket = assign(socket, :form, to_form(changeset, action: :validate))

    {:noreply, socket}
  end

  def handle_event("save", %{"response" => response_params}, socket) do
    %{incident: incident, current_user: user} = socket.assigns

    case Responses.create_response(incident, user, response_params) do
      {:ok, _response} ->
        changeset = Responses.change_response(%Response{})

        socket = assign(socket, :form, to_form(changeset))

        {:noreply, socket}

      {:error, changeset} ->
        socket = assign(socket, :form, to_form(changeset))

        {:noreply, socket}
    end
  end

  def handle_info({:response_created, response}, socket) do
    socket =
      socket
      |> stream_insert(:responses, response, at: 0)
      |> update(:response_count, &(&1 + 1))

    {:noreply, socket}
  end

  def handle_info({:incident_updated, updated_incident}, socket) do
    {:noreply, assign(socket, :incident, updated_incident)}
  end
end
