defmodule Zorn.Game.Blacksmith do
  @moduledoc """
  The Blacksmith context for equipment upgrades.
  """

  alias Zorn.Game
  alias Zorn.Repo

  @upgrade_cost_multiplier 1.5

  @doc """
  Upgrades a piece of equipment owned by the user.
  Returns {:ok, updated_item} or {:error, reason}
  """
  def upgrade_equipment(user_id, item_id) do
    Repo.transaction(fn ->
      # Check if user has the equipment
      case Game.get_user_item(user_id, item_id) do
        nil ->
          Repo.rollback(:item_not_found)

        _user_item ->
          # Get item details
          item = Game.get_item!(item_id)

          # Check if it's equipment
          if item.type != :equipment do
            Repo.rollback(:not_equipment)
          else
            # Calculate upgrade cost (base_value * multiplier)
            upgrade_cost = trunc(item.base_value * @upgrade_cost_multiplier)

            # Check if user has enough gold
            user_gold = Game.get_user_gold(user_id)

            if user_gold < upgrade_cost do
              Repo.rollback(:insufficient_funds)
            else
              # Spend gold
              case Game.spend_gold(user_id, upgrade_cost) do
                {:ok, _user} ->
                  # Update item's base_value (representing upgrade level)
                  new_base_value = trunc(item.base_value * @upgrade_cost_multiplier)

                  case Game.update_item(item, %{base_value: new_base_value}) do
                    {:ok, updated_item} -> updated_item
                    {:error, changeset} -> Repo.rollback(changeset)
                  end

                {:error, reason} ->
                  Repo.rollback(reason)
              end
            end
          end
      end
    end)
  end

  @doc """
  Gets the user's equipment items.
  """
  def get_user_equipment(user_id) do
    inventory = Game.get_user_inventory(user_id)

    inventory
    |> Enum.filter(fn user_item -> user_item.item.type == :equipment end)
  end

  @doc """
  Calculates the upgrade cost for an equipment item.
  """
  def calculate_upgrade_cost(item) do
    trunc(item.base_value * @upgrade_cost_multiplier)
  end
end
