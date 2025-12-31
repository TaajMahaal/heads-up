defmodule HeadsUp.Incidents.Incident do
  use HeadsUp.Schema, prefix: "icd"

  schema "incidents" do
    field :name, :string
    field :description, :string
    field :priority, :integer
    field :status, Ecto.Enum, values: [:pending, :resolved, :canceled], default: :pending
    field :image_path, :string, default: "/images/placeholder.jpg"

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(incident, attrs) do
    incident
    |> cast(attrs, [:name, :description, :priority, :status, :image_path])
    |> validate_required([:name, :description, :priority, :status, :image_path])
    |> validate_length(:description, min: 10)
    |> validate_number(
      :priority,
      greater_than_or_equal_to: 1,
      less_than_or_equal_to: 3
    )
  end
end
