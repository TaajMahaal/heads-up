defmodule HeadsUpWeb.IncidentLive.Index do
  import HeadsUpWeb.IncidentComponents

  use HeadsUpWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :incidents, HeadsUp.Incidents.list_incidents())}
  end

  def render(assigns) do
    ~H"""
    <div class="incident-index">
      <.headline :let={vibe}>
        <.icon name="hero-trophy-mini" /> 25 Incidents Resolved This Month! {vibe}
        <:tagline>
          Thanks for pitching in.
        </:tagline>
      </.headline>
      <div class="incidents">
        <.incident_card :for={incident <- @incidents} incident={incident} />
      </div>
    </div>
    """
  end
end
