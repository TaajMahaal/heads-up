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

  attr :form, Phoenix.HTML.Form, required: true

  def filter_form(assigns) do
    ~H"""
    <.form for={@form} id="filter-form" phx-change="filter" phx-submit="filter">
      <.input
        field={@form[:q]}
        placeholder="Search..."
        autocomplete="off"
        phx-debounce="500"
      />

      <.input
        type="select"
        field={@form[:status]}
        prompt="Status"
        options={[:pending, :resolved, :canceled]}
      />

      <.input
        type="select"
        field={@form[:sort_by]}
        prompt="Sort by"
        options={[
          Status: "status",
          "Priority: High to Low": "priority_desc",
          "Priority: Low to High": "priority_asc"
        ]}
      />

      <.link navigate={~p"/incidents"} class="button bg-white text-blue-950">
        Reset
      </.link>
    </.form>
    """
  end

  attr :incidents, :list, required: true

  def urgent_incidents(assigns) do
    ~H"""
    <section>
      <h4>
        <div class="text-gray-100">
          Urgent Incidents
        </div>
      </h4>
      <ul class="incidents">
        <%= for incident <- @incidents do %>
          <li>
            <.link navigate={~p"/incidents/#{incident}"}>
              <img src={"#{incident.image_path}"} />
              <div class="text-gray-100">
                {"#{incident.name}"}
              </div>
            </.link>
          </li>
        <% end %>
      </ul>
    </section>
    """
  end
end
