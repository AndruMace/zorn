defmodule Zorn.Game.Adventures do
  @moduledoc """
  The Adventures context for handling adventure completion and rewards.
  """

  alias Zorn.Game
  alias Zorn.Repo

  @doc """
  Completes an adventure and rewards the user with random gold, loot items, and sellable items.
  Returns {:ok, rewards} where rewards is a map with :gold, :loot_items, and :sellable_items.
  """
  def complete_adventure(user_id) do
    # Seed random number generator if not already seeded
    :rand.seed(:exs1024, :erlang.timestamp())

    # Random gold reward between 10-50
    gold_reward = :rand.uniform(41) + 9

    # Get random loot items (0-2 items)
    loot_items = get_random_loot_items(:rand.uniform(3))

    # Get random sellable items (0-2 items)
    sellable_items = get_random_sellable_items(:rand.uniform(3))

    # Apply rewards in a transaction
    Repo.transaction(fn ->
      # Add gold
      case Game.add_gold(user_id, gold_reward) do
        {:ok, _user} -> :ok
        {:error, changeset} -> Repo.rollback(changeset)
      end

      # Add loot items
      Enum.each(loot_items, fn item ->
        case Game.add_item_to_inventory(user_id, item.id, 1) do
          {:ok, _} -> :ok
          {:error, changeset} -> Repo.rollback(changeset)
        end
      end)

      # Add sellable items
      Enum.each(sellable_items, fn item ->
        case Game.add_item_to_inventory(user_id, item.id, 1) do
          {:ok, _} -> :ok
          {:error, changeset} -> Repo.rollback(changeset)
        end
      end)

      %{
        gold: gold_reward,
        loot_items: loot_items,
        sellable_items: sellable_items
      }
    end)
  end

  defp get_random_loot_items(count) when count > 0 do
    loot_items = Game.list_items_by_type(:loot)

    if Enum.empty?(loot_items) do
      []
    else
      loot_items
      |> Enum.shuffle()
      |> Enum.take(count)
    end
  end

  defp get_random_loot_items(_), do: []

  defp get_random_sellable_items(count) when count > 0 do
    sellable_items = Game.list_items_by_type(:sellable)

    if Enum.empty?(sellable_items) do
      []
    else
      sellable_items
      |> Enum.shuffle()
      |> Enum.take(count)
    end
  end

  defp get_random_sellable_items(_), do: []
end
