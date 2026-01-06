defmodule HeadsUp.Categories.Category do
  use HeadsUp.Schema, prefix: "ctg"

  schema "categories" do
    field :name, :string
    field :slug, :string

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
  end
end
