defmodule ZornWeb.MerchantLive do
  use ZornWeb, :live_view

  alias Zorn.Game.Merchant
  alias Zorn.Game

  @impl true
  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_scope.users.id
    gold = Game.get_user_gold(user_id)
    inventory = Game.get_user_inventory(user_id)
    merchant_items = Merchant.get_merchant_items()

    {:ok,
     socket
     |> assign(:gold, gold)
     |> assign(:inventory, inventory)
     |> assign(:merchant_items, merchant_items)}
  end

  @impl true
  def handle_event("buy", %{"item_id" => item_id}, socket) do
    user_id = socket.assigns.current_scope.users.id

    case Merchant.buy_item(user_id, String.to_integer(item_id), 1) do
      {:ok, _user_item} ->
        gold = Game.get_user_gold(user_id)
        inventory = Game.get_user_inventory(user_id)

        {:noreply,
         socket
         |> assign(:gold, gold)
         |> assign(:inventory, inventory)
         |> put_flash(:info, "Item purchased!")}

      {:error, :insufficient_funds} ->
        {:noreply, put_flash(socket, :error, "Not enough gold!")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to purchase item")}
    end
  end

  @impl true
  def handle_event("sell", %{"item_id" => item_id}, socket) do
    user_id = socket.assigns.current_scope.users.id

    case Merchant.sell_item(user_id, String.to_integer(item_id), 1) do
      {:ok, gold_earned} ->
        gold = Game.get_user_gold(user_id)
        inventory = Game.get_user_inventory(user_id)

        {:noreply,
         socket
         |> assign(:gold, gold)
         |> assign(:inventory, inventory)
         |> put_flash(:info, "Sold for #{gold_earned} gold!")}

      {:error, :item_not_found} ->
        {:noreply, put_flash(socket, :error, "Item not found in inventory")}

      {:error, :insufficient_quantity} ->
        {:noreply, put_flash(socket, :error, "Not enough items to sell")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to sell item")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="space-y-8">
        <.header>
          Merchant
          <:subtitle>Buy and sell goods</:subtitle>
        </.header>

        <div class="max-w-6xl mx-auto grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div class="card bg-base-100 shadow-xl">
            <div class="card-body">
              <h2 class="card-title">Your Inventory</h2>
              <div class="flex justify-between items-center mb-4">
                <span>Gold:</span>
                <span class="text-xl font-bold text-primary">{@gold}</span>
              </div>

              <div class="divider"></div>

              <%= if Enum.empty?(@inventory) do %>
                <p class="text-center text-base-content/70">Your inventory is empty</p>
              <% else %>
                <div class="space-y-2">
                  <%= for user_item <- @inventory do %>
                    <%= if user_item.item.type == :sellable do %>
                      <div class="flex justify-between items-center p-3 bg-base-200 rounded">
                        <div>
                          <p class="font-semibold">{user_item.item.name}</p>
                          <p class="text-sm text-base-content/70">
                            Quantity: {user_item.quantity} | Value: {user_item.item.base_value} gold
                          </p>
                        </div>
                        <button
                          phx-click="sell"
                          phx-value-item_id={user_item.item_id}
                          class="btn btn-sm btn-primary"
                        >
                          Sell
                        </button>
                      </div>
                    <% end %>
                  <% end %>
                </div>
              <% end %>
            </div>
          </div>

          <div class="card bg-base-100 shadow-xl">
            <div class="card-body">
              <h2 class="card-title">Merchant's Shop</h2>

              <div class="divider"></div>

              <%= if Enum.empty?(@merchant_items) do %>
                <p class="text-center text-base-content/70">No items available</p>
              <% else %>
                <div class="space-y-2">
                  <%= for item <- @merchant_items do %>
                    <div class="flex justify-between items-center p-3 bg-base-200 rounded">
                      <div>
                        <p class="font-semibold">{item.name}</p>
                        <p class="text-sm text-base-content/70">
                          {item.description || "No description"}
                        </p>
                        <p class="text-sm font-semibold text-primary">{item.base_value} gold</p>
                      </div>
                      <button
                        phx-click="buy"
                        phx-value-item_id={item.id}
                        class="btn btn-sm btn-primary"
                      >
                        Buy
                      </button>
                    </div>
                  <% end %>
                </div>
              <% end %>
            </div>
          </div>
        </div>

        <div class="text-center">
          <.link navigate={~p"/home"} class="btn btn-ghost">
            Back to Home
          </.link>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
