defmodule Zorn.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :name, :string, null: false
      add :description, :text
      add :type, :string, null: false
      add :base_value, :integer, null: false, default: 0

      timestamps(type: :utc_datetime)
    end

    create index(:items, [:type])
  end
end
