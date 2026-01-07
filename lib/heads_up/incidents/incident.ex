defmodule HeadsUp.Incidents.Incident do
  use HeadsUp.Schema, prefix: "icd"

  schema "incidents" do
    field :name, :string
    field :description, :string
    field :priority, :integer
    field :status, Ecto.Enum, values: [:pending, :resolved, :canceled], default: :pending
    field :image_path, :string, default: "/images/placeholder.jpg"

    belongs_to :category, HeadsUp.Categories.Category

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
