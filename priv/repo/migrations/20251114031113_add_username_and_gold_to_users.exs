defmodule Zorn.Repo.Migrations.AddUsernameAndGoldToUsers do
  use Ecto.Migration

  def change do
    alter table(:user) do
      add :username, :string, null: false, default: ""
      add :gold, :integer, null: false, default: 100
    end

    create unique_index(:user, [:username])

    # Update existing users: generate username from email and set gold to 100
    execute """
    UPDATE "user"
    SET username = split_part(email, '@', 1) || '_' || id::text,
        gold = 100
    WHERE username = '';
    """, ""
  end
end
