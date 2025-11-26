defmodule Zorn.Game.Merchant do
  @moduledoc """
  The Merchant context for buying and selling items.
  """

  alias Zorn.Game
  alias Zorn.Repo

  @doc """
  Sells an item from the user's inventory for gold.
  Returns {:ok, gold_earned} or {:error, reason}
  """
  def sell_item(user_id, item_id, quantity \\ 1) do
    Repo.transaction(fn ->
      # Check if user has the item
      case Game.get_user_item(user_id, item_id) do
        nil ->
          Repo.rollback(:item_not_found)

        user_item when user_item.quantity < quantity ->
          Repo.rollback(:insufficient_quantity)

        _user_item ->
          # Get item details
          item = Game.get_item!(item_id)

          # Calculate gold earned
          gold_earned = item.base_value * quantity

          # Remove item from inventory
          case Game.remove_item_from_inventory(user_id, item_id, quantity) do
            {:ok, _} ->
              # Add gold
              case Game.add_gold(user_id, gold_earned) do
                {:ok, _user} -> gold_earned
                {:error, changeset} -> Repo.rollback(changeset)
              end

            {:error, reason} ->
              Repo.rollback(reason)
          end
      end
    end)
  end

  @doc """
  Buys an item for the user using gold.
  Returns {:ok, user_item} or {:error, reason}
  """
  def buy_item(user_id, item_id, quantity \\ 1) do
    Repo.transaction(fn ->
      # Get item details
      item = Game.get_item!(item_id)

      # Calculate total cost
      total_cost = item.base_value * quantity

      # Check if user has enough gold
      user_gold = Game.get_user_gold(user_id)

      if user_gold < total_cost do
        Repo.rollback(:insufficient_funds)
      else
        # Spend gold
        case Game.spend_gold(user_id, total_cost) do
          {:ok, _user} ->
            # Add item to inventory
            case Game.add_item_to_inventory(user_id, item_id, quantity) do
              {:ok, user_item} -> user_item
              {:error, changeset} -> Repo.rollback(changeset)
            end

          {:error, reason} ->
            Repo.rollback(reason)
        end
      end
    end)
  end

  @doc """
  Gets items available for purchase from the merchant.
  Currently returns all sellable items.
  """
  def get_merchant_items do
    Game.list_items_by_type(:sellable)
  end
end
