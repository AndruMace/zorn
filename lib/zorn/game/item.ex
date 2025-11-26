defmodule Zorn.Game.Item do
  use Ecto.Schema
  import Ecto.Changeset

  @types ~w(loot sellable equipment)a

  schema "items" do
    field :name, :string
    field :description, :string
    field :type, Ecto.Enum, values: @types
    field :base_value, :integer, default: 0

    has_many :user_items, Zorn.Game.UserItem

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :description, :type, :base_value])
    |> validate_required([:name, :type])
    |> validate_inclusion(:type, @types)
    |> validate_number(:base_value, greater_than_or_equal_to: 0)
  end
end
