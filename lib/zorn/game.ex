defmodule Zorn.Game do
  @moduledoc """
  The Game context.
  """

  import Ecto.Query, warn: false
  alias Zorn.Repo

  alias Zorn.Game.{Item, UserItem}
  alias Zorn.Accounts.Users

  ## Item functions

  @doc """
  Returns the list of items.
  """
  def list_items do
    Repo.all(Item)
  end

  @doc """
  Gets a single item.
  """
  def get_item!(id), do: Repo.get!(Item, id)

  @doc """
  Gets an item by name.
  """
  def get_item_by_name(name), do: Repo.get_by(Item, name: name)

  @doc """
  Creates an item.
  """
  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an item.
  """
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an item.
  """
  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  ## Inventory functions

  @doc """
  Gets all items in a user's inventory.
  """
  def get_user_inventory(user_id) do
    from(ui in UserItem,
      where: ui.user_id == ^user_id,
      preload: [:item]
    )
    |> Repo.all()
  end

  @doc """
  Gets a user's inventory item by item_id.
  """
  def get_user_item(user_id, item_id) do
    Repo.get_by(UserItem, user_id: user_id, item_id: item_id)
  end

  @doc """
  Adds an item to a user's inventory. If the item already exists, increments quantity.
  """
  def add_item_to_inventory(user_id, item_id, quantity \\ 1) do
    case get_user_item(user_id, item_id) do
      nil ->
        %UserItem{}
        |> UserItem.changeset(%{user_id: user_id, item_id: item_id, quantity: quantity})
        |> Repo.insert()

      user_item ->
        user_item
        |> UserItem.changeset(%{quantity: user_item.quantity + quantity})
        |> Repo.update()
    end
  end

  @doc """
  Removes an item from a user's inventory or decreases quantity.
  """
  def remove_item_from_inventory(user_id, item_id, quantity \\ 1) do
    case get_user_item(user_id, item_id) do
      nil ->
        {:error, :not_found}

      user_item when user_item.quantity <= quantity ->
        Repo.delete(user_item)

      user_item ->
        user_item
        |> UserItem.changeset(%{quantity: user_item.quantity - quantity})
        |> Repo.update()
    end
  end

  ## Gold functions

  @doc """
  Gets a user's current gold amount.
  """
  def get_user_gold(user_id) do
    user = Repo.get!(Users, user_id)
    user.gold
  end

  @doc """
  Adds gold to a user's account.
  """
  def add_gold(user_id, amount) when amount > 0 do
    user = Repo.get!(Users, user_id)

    user
    |> Users.changeset(%{gold: user.gold + amount})
    |> Repo.update()
  end

  @doc """
  Spends gold from a user's account. Returns error if insufficient funds.
  """
  def spend_gold(user_id, amount) when amount > 0 do
    user = Repo.get!(Users, user_id)

    if user.gold >= amount do
      user
      |> Users.changeset(%{gold: user.gold - amount})
      |> Repo.update()
    else
      {:error, :insufficient_funds}
    end
  end

  @doc """
  Returns a changeset for updating user gold.
  """
  def change_user_gold(%Users{} = user, attrs \\ %{}) do
    Users.changeset(user, attrs)
  end

  @doc """
  Gets items by type.
  """
  def list_items_by_type(type) when type in [:loot, :sellable, :equipment] do
    from(i in Item, where: i.type == ^type)
    |> Repo.all()
  end
end
