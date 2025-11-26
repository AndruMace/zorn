# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Zorn.Repo.insert!(%Zorn.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Zorn.Game
alias Zorn.Repo

# Loot Items
loot_items = [
  %{
    name: "Ancient Scroll",
    description: "A mysterious scroll with ancient writings",
    type: :loot,
    base_value: 0
  },
  %{
    name: "Magic Crystal",
    description: "A glowing crystal pulsing with magical energy",
    type: :loot,
    base_value: 0
  },
  %{
    name: "Dragon Scale",
    description: "A rare scale from a legendary dragon",
    type: :loot,
    base_value: 0
  },
  %{
    name: "Enchanted Gem",
    description: "A gem that seems to shimmer with inner light",
    type: :loot,
    base_value: 0
  }
]

# Sellable Items
sellable_items = [
  %{
    name: "Iron Ore",
    description: "Raw iron ore that can be sold",
    type: :sellable,
    base_value: 10
  },
  %{
    name: "Gold Nugget",
    description: "A small nugget of pure gold",
    type: :sellable,
    base_value: 25
  },
  %{
    name: "Precious Gem",
    description: "A valuable gemstone",
    type: :sellable,
    base_value: 50
  },
  %{
    name: "Rare Herb",
    description: "A rare medicinal herb",
    type: :sellable,
    base_value: 15
  },
  %{
    name: "Silver Coin",
    description: "An old silver coin",
    type: :sellable,
    base_value: 5
  }
]

# Equipment Items
equipment_items = [
  %{
    name: "Iron Sword",
    description: "A basic iron sword",
    type: :equipment,
    base_value: 100
  },
  %{
    name: "Leather Armor",
    description: "Lightweight leather armor",
    type: :equipment,
    base_value: 80
  },
  %{
    name: "Steel Shield",
    description: "A sturdy steel shield",
    type: :equipment,
    base_value: 120
  },
  %{
    name: "Mage Robe",
    description: "A robe imbued with magical properties",
    type: :equipment,
    base_value: 150
  }
]

# Insert items only if they don't exist
Enum.each(loot_items ++ sellable_items ++ equipment_items, fn item_attrs ->
  case Game.get_item_by_name(item_attrs.name) do
    nil ->
      %Zorn.Game.Item{}
      |> Zorn.Game.Item.changeset(item_attrs)
      |> Repo.insert!()

    _existing ->
      :ok
  end
end)

IO.puts("Seeded #{length(loot_items)} loot items, #{length(sellable_items)} sellable items, and #{length(equipment_items)} equipment items")
