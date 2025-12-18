defmodule HeadsUp.Incidents.Incident do
  use HeadsUp.Schema, prefix: "icd"

  schema "incidents" do
    field :name, :string
    field :description, :string
    field :priority, :integer
    field :status, Ecto.Enum, values: [:pending, :resolved, :closed]
    field :image_path, :string

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(incident, attrs) do
    incident
    |> cast(attrs, [:name, :description, :priority, :status, :image_path])
    |> validate_required([:name, :description, :priority, :status, :image_path])
  end
end
