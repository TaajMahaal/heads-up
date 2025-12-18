defmodule HeadsUp.Repo.Migrations.CreateIncidents do
  use Ecto.Migration

  def change do
    create table(:incidents, primary_key: false) do
      add :id, :string, primary_key: true

      add :name, :string
      add :description, :string
      add :priority, :integer
      add :status, :string
      add :image_path, :string

      timestamps(type: :utc_datetime_usec)
    end


  end
end
