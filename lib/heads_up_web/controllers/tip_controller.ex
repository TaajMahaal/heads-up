defmodule HeadsUpWeb.TipController do
  use HeadsUpWeb, :controller
  alias HeadsUp.Tips

  def index(conn, _params) do
    conn = assign(conn, :tips, Tips.list_tips())
    conn = assign(conn, :emojis, ~w(💚 💜 💙) |> Enum.random() |> String.duplicate(5))

    render(conn, :index)
  end

  def show(conn, %{"id" => id}) do
    conn = assign(conn, :tip, Tips.get_tip(id))

    render(conn, :show)
  end
end
