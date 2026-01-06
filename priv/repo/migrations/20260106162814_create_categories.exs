defmodule HeadsUp.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories, primary_key: false) do
      add :id, :string, primary_key: true

      add :name, :string
      add :slug, :string

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:categories, [:slug])
    create unique_index(:categories, [:name])

  end
end
