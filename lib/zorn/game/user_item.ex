defmodule Zorn.Game.UserItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_items" do
    field :quantity, :integer, default: 1

    belongs_to :user, Zorn.Accounts.Users
    belongs_to :item, Zorn.Game.Item

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_item, attrs) do
    user_item
    |> cast(attrs, [:quantity, :user_id, :item_id])
    |> validate_required([:quantity, :user_id, :item_id])
    |> validate_number(:quantity, greater_than: 0)
    |> unique_constraint([:user_id, :item_id])
  end
end
