defmodule HeadsUp.Categories.Category do
  use HeadsUp.Schema, prefix: "ctg"

  schema "categories" do
    field :name, :string
    field :slug, :string

    has_many :incidents, HeadsUp.Incidents.Incident

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
  end
end

defimpl Jason.Encoder, for: HeadsUp.Categories.Category do
  def encode(category, opts) do
    %{
      id: category.id,
      name: category.name,
      slug: category.slug
    }
    |> put_if_loaded(:incidents, category.incidents)
    |> Jason.Encode.map(opts)
  end

  defp put_if_loaded(map, _key, %Ecto.Association.NotLoaded{}), do: map
  defp put_if_loaded(map, key, value) when is_list(value), do: Map.put(map, key, value)
  defp put_if_loaded(map, key, %{} = value), do: Map.put(map, key, value)
end
