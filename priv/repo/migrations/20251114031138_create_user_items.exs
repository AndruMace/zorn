defmodule Zorn.Repo.Migrations.CreateUserItems do
  use Ecto.Migration

  def change do
    create table(:user_items) do
      add :user_id, references(:user, on_delete: :delete_all), null: false
      add :item_id, references(:items, on_delete: :delete_all), null: false
      add :quantity, :integer, null: false, default: 1

      timestamps(type: :utc_datetime)
    end

    create unique_index(:user_items, [:user_id, :item_id])
    create index(:user_items, [:user_id])
    create index(:user_items, [:item_id])
  end
end
