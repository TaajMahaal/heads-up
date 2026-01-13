defmodule HeadsUpWeb.CustomComponents do
  use Phoenix.Component

  alias HeadsUp.Responses.Response

  import HeadsUpWeb.CoreComponents

  attr :status, :atom, values: [:pending, :resolved, :canceled], default: :pending
  attr :class, :atom, default: nil
  attr :rest, :global

  def badge(assigns) do
    ~H"""
    <div
      class={[
        "rounded-md px-2 py-1 text-xs font-medium uppercase inline-block border",
        @status == :pending && "text-amber-600 border-yellow-600",
        @status == :resolved && "text-lime-600 border-lime-600",
        @status == :canceled && "text-gray-600 border-gray-600"
      ]}
      {@rest}
    >
      {@status}
    </div>
    """
  end

  attr :priority, :integer, default: 3
  attr :rest, :global

  def priority(assigns) do
    ~H"""
    <div
      class={[
        "text-xs text-white font-medium rounded-full px-3 py-1.5 w-10 text-center",
        @priority == 1 && "bg-purple-600",
        @priority == 2 && "bg-red-600",
        @priority == 3 && "bg-yellow-600"
      ]}
      {@rest}
    >
      {@priority}
    </div>
    """
  end

  slot :inner_block, required: true
  slot :tagline, required: true

  def headline(assigns) do
    assigns = assign(assigns, :emoji, ~w(😎 🤩 🥳) |> Enum.random())

    ~H"""
    <div class="headline">
      <h1>
        {render_slot(@inner_block, @emoji)}
      </h1>
      <div class="tagline">
        {render_slot(@tagline)}
      </div>
    </div>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true

  def response_form(assigns) do
    ~H"""
    <.form for={@form} id="response-form" phx-change="validate" phx-submit="save">
        <.input
            field={@form[:status]}
            type="select"
            prompt="Choose a status"
            options={[:enroute, :arrived, :departed]} />

        <.input field={@form[:note]}
            type="textarea"
            placeholder="Note..."
            autofocus />

        <.button>Post</.button>
    </.form>
    """
  end


  attr :id, :string, required: true
  attr :response, Response, required: true

  def response(assigns) do
    ~H"""
    <div class="response" id={@id}>
      <span class="timeline"></span>
      <section>
        <div class="avatar">
          <.icon name="hero-user-solid" />
        </div>
        <div>
          <span class="username">
            {@response.user.username}
          </span>
          <span>
            {@response.status}
          </span>
          <blockquote>
            {@response.note}
          </blockquote>
        </div>
      </section>
    </div>
    """
  end
end
