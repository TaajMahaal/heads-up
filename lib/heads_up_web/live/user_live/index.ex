defmodule HeadsUpWeb.UserLive.Index do
  use HeadsUpWeb, :live_view

  alias HeadsUp.Accounts

  def mount(_params, _session, socket) do
    users = Accounts.list_users()

    socket = stream(socket, :users, users)

    {:ok, socket}
  end

  def handle_event("promote", %{"id" => id}, socket) do
    if id == socket.assigns.current_user.id do
      put_flash(socket, :error, "You can't promote yourself.")
      {:noreply, socket}
    end

    {:ok, user} = Accounts.get_user!(id)
                  |> Accounts.promote_to_admin()

    socket =
      socket
      |> stream_insert(:users, user)
      |> put_flash(:info, "User #{user.username} demoted successfully")

    {:noreply, socket}
  end

  def handle_event("demote", %{"id" => id}, socket) do
    if id == socket.assigns.current_user.id do
      put_flash(socket, :error, "You can't demote yourself.")
      {:noreply, socket}
    end

    {:ok, user} = Accounts.get_user!(id)
                  |> Accounts.demote_from_admin()

    socket =
      socket
      |> stream_insert(:users, user)
      |> put_flash(:info, "User #{user.username} demoted successfully")

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <.header>
      Listing Users
    </.header>

    <.table id="users" rows={@streams.users} >
      <:col :let={{_id, user}} label="Username">{user.username}</:col>
      <:col :let={{_id, user}} label="Email">{user.email}</:col>
      <:col :let={{_id, user}} label="Role">
        <%= if user.is_admin do %>
          Admin
          <% else %>
          User
          <% end %>
        </:col>
      <:action :let={{_id, user}}>
        <%= if not user.is_admin do %>
          <.link
            phx-click={JS.push("promote", value: %{id: user.id})}
            data-confirm="Are you sure?"
          >
            Promote Admin
          </.link>
        <% else %>
          <%= if user.id != @current_user.id do %>
            <.link
              phx-click={JS.push("demote", value: %{id: user.id})}
              data-confirm="Remove admin privileges?"
            >
              Demote
            </.link>
          <% end %>
        <% end %>
      </:action>
    </.table>
    """
  end
end
