defmodule HeadsUp.Repo.Migrations.CreateResponses do
  use Ecto.Migration

  def change do
    create table(:responses, primary_key: false) do
      add :id, :string, primary_key: true

      add :note, :text
      add :status, :string
      add :incident_id, references(:incidents, type: :string, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :string, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:responses, [:incident_id])
    create index(:responses, [:user_id])
  end
end
