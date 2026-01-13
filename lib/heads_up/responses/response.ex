defmodule HeadsUp.Responses.Response do
  use HeadsUp.Schema, prefix: "rsp"

  schema "responses" do
    field :note, :string
    field :status, Ecto.Enum, values: [:enroute, :arrived, :departed]

    belongs_to :incident, HeadsUp.Incidents.Incident
    belongs_to :user, HeadsUp.Accounts.User

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(response, attrs) do
    response
    |> cast(attrs, [:note, :status, :incident_id, :user_id])
    |> validate_required([:note, :status, :incident_id, :user_id])
    |> validate_length(:note, max: 500)
    |> assoc_constraint(:incident)
    |> assoc_constraint(:user)
  end
end
