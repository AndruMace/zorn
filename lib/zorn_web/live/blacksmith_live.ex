defmodule ZornWeb.BlacksmithLive do
  use ZornWeb, :live_view

  alias Zorn.Game.Blacksmith
  alias Zorn.Game

  @impl true
  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_scope.users.id
    gold = Game.get_user_gold(user_id)
    equipment = Blacksmith.get_user_equipment(user_id)

    {:ok,
     socket
     |> assign(:gold, gold)
     |> assign(:equipment, equipment)}
  end

  @impl true
  def handle_event("upgrade", %{"item_id" => item_id}, socket) do
    user_id = socket.assigns.current_scope.users.id

    case Blacksmith.upgrade_equipment(user_id, String.to_integer(item_id)) do
      {:ok, _updated_item} ->
        gold = Game.get_user_gold(user_id)
        equipment = Blacksmith.get_user_equipment(user_id)

        {:noreply,
         socket
         |> assign(:gold, gold)
         |> assign(:equipment, equipment)
         |> put_flash(:info, "Equipment upgraded!")}

      {:error, :item_not_found} ->
        {:noreply, put_flash(socket, :error, "Equipment not found")}

      {:error, :not_equipment} ->
        {:noreply, put_flash(socket, :error, "This is not equipment")}

      {:error, :insufficient_funds} ->
        {:noreply, put_flash(socket, :error, "Not enough gold!")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to upgrade equipment")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="space-y-8">
        <.header>
          Blacksmith
          <:subtitle>Forge weapons and armor</:subtitle>
        </.header>

        <div class="max-w-4xl mx-auto">
          <div class="card bg-base-100 shadow-xl">
            <div class="card-body">
              <div class="flex justify-between items-center mb-4">
                <h2 class="card-title">Your Equipment</h2>
                <div class="text-xl font-bold text-primary">Gold: {@gold}</div>
              </div>

              <div class="divider"></div>

              <%= if Enum.empty?(@equipment) do %>
                <p class="text-center text-base-content/70">You have no equipment</p>
              <% else %>
                <div class="space-y-4">
                  <%= for user_item <- @equipment do %>
                    <div class="flex justify-between items-center p-4 bg-base-200 rounded-lg">
                      <div class="flex-1">
                        <p class="font-semibold text-lg">{user_item.item.name}</p>
                        <p class="text-sm text-base-content/70">
                          {user_item.item.description || "No description"}
                        </p>
                        <p class="text-sm mt-2">
                          Current Level: <span class="font-semibold">{user_item.item.base_value}</span>
                        </p>
                        <p class="text-sm text-primary">
                          Upgrade Cost: {Blacksmith.calculate_upgrade_cost(user_item.item)} gold
                        </p>
                      </div>
                      <button
                        phx-click="upgrade"
                        phx-value-item_id={user_item.item_id}
                        class="btn btn-primary"
                      >
                        <.icon name="hero-arrow-up" class="w-5 h-5 mr-2" />
                        Upgrade
                      </button>
                    </div>
                  <% end %>
                </div>
              <% end %>

              <div class="card-actions justify-end mt-6">
                <.link navigate={~p"/home"} class="btn btn-ghost">
                  Back to Home
                </.link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
