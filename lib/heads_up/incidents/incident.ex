defmodule HeadsUp.Incidents.Incident do
  use HeadsUp.Schema, prefix: "icd"

  schema "incidents" do
    field :name, :string
    field :description, :string
    field :priority, :integer
    field :status, Ecto.Enum, values: [:pending, :resolved, :canceled], default: :pending
    field :image_path, :string, default: "/images/placeholder.jpg"

    belongs_to :category, HeadsUp.Categories.Category

    has_many :responses, HeadsUp.Responses.Response

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(incident, attrs) do
    incident
    |> cast(attrs, [:name, :description, :priority, :status, :image_path, :category_id])
    |> validate_required([:name, :description, :priority, :status, :image_path, :category_id])
    |> validate_length(:description, min: 10)
    |> validate_number(
      :priority,
      greater_than_or_equal_to: 1,
      less_than_or_equal_to: 3
    )
    |> assoc_constraint(:category)
  end
end

defimpl Jason.Encoder, for: HeadsUp.Incidents.Incident do
  def encode(incident, opts) do
    %{
      id: incident.id,
      name: incident.name,
      description: incident.description,
      priority: incident.priority,
      status: incident.status,
      category_id: incident.category_id
    }
    |> put_if_loaded(:category, incident.category)
    |> Jason.Encode.map(opts)
  end

  defp put_if_loaded(map, _key, %Ecto.Association.NotLoaded{}), do: map
  defp put_if_loaded(map, key, value) when is_list(value), do: Map.put(map, key, value)
  defp put_if_loaded(map, key, %{} = value), do: Map.put(map, key, value)
end
