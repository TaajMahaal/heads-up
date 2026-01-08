defmodule HeadsUpWeb.Api.CategoryJSON do
  def index(%{categories: categories}) do
    %{categories: categories}
  end

  def show(%{category: category}), do: category
end
