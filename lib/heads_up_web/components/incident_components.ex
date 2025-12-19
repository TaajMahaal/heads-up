defmodule HeadsUpWeb.IncidentComponents do
  use HeadsUpWeb, :html

  import HeadsUpWeb.CustomComponents

  attr :incident, HeadsUp.Incidents.Incident, required: true
  attr :id, :string, required: true

  def incident_card(assigns) do
    ~H"""
    <.link navigate={~p"/incidents/#{@incident}"} id={@id}>
      <div class="card">
        <img src={@incident.image_path} />
        <h2>{@incident.name}</h2>
        <div class="details">
          <.badge status={@incident.status} />
          <.priority priority={@incident.priority} />
        </div>
      </div>
    </.link>
    """
  end

  attr :incidents, :list, required: true

  def urgent_incidents(assigns) do
    ~H"""
    <section>
      <h4>Urgent Incidents</h4>
      <ul class="incidents">
        <%= for incident <- @incidents do %>
          <li>
            <.link navigate={~p"/incidents/#{incident}"}>
              <img src={"#{incident.image_path}"} />
              {"#{incident.name}"}
            </.link>
          </li>
        <% end %>
      </ul>
    </section>
    """
  end
end
