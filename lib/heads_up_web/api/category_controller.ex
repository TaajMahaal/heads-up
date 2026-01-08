defmodule HeadsUpWeb.Api.CategoryController do
  use HeadsUpWeb, :controller

  alias HeadsUp.Categories

  def index(conn, _params) do
    categories = Categories.list_categories()

    render(conn, :index, categories: categories)
  end

  def show(conn, %{"id" => id}), do: get_category(conn, id)

  def incidents(conn, %{"id" => id}), do: get_category(conn, id, :incidents)

  defp get_category(conn, id, preloads \\ []) do
    category = Categories.get_category!(id, preloads)

    render(conn, :show, category: category, preloads: preloads)
  rescue
    Ecto.NoResultsError ->
      conn
      |> put_status(:not_found)
      |> put_view(json: HeadsUpWeb.ErrorJSON)
      |> render(:"404")
  end
end
