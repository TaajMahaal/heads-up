defmodule HeadsUpWeb.IncidentComponents do
  use HeadsUpWeb, :html

  attr :incident, HeadsUp.Incidents.Incident, required: true
  attr :id, :string, required: true

  def incident_card(assigns) do
    ~H"""
    <.link navigate={~p"/incidents/#{@incident}"} id={@id}>
      <div class="card">
        <div class="category">
          {@incident.category.name}
        </div>
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
  attr :category_options, :list, required: true

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
        field={@form[:category]}
        prompt="Category"
        options={@category_options}
      />

      <.input
        type="select"
        field={@form[:sort_by]}
        prompt="Sort by"
        options={[
          Status: "status",
          "Priority: High to Low": "priority_desc",
          "Priority: Low to High": "priority_asc",
          Category: "category"
        ]}
      />

      <.link patch={~p"/incidents"} class="button">
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
        <div>
          Urgent Incidents
        </div>
      </h4>
      <.async_result :let={result} assign={@incidents}>
        <:loading>
          <div class="loading">
            <div class="spinner"></div>
          </div>
        </:loading>
        <:failed :let={{:error, reason}}>
          <div class="failed">
            Da shit broke bro: {reason}
          </div>
        </:failed>
        <ul class="incidents">
          <li :for={incident <- result}>
            <.link navigate={~p"/incidents/#{incident}"}>
              <img src={"#{incident.image_path}"} />
              <div>
                {"#{incident.name}"}
              </div>
            </.link>
          </li>
        </ul>
      </.async_result>
    </section>
    """
  end
end
