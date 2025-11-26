defmodule ZornWeb.AdventureLive do
  use ZornWeb, :live_view

  alias Zorn.Game.Adventures
  alias Zorn.Game

  @impl true
  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_scope.users.id
    gold = Game.get_user_gold(user_id)

    {
      :ok,
      socket
      |> assign(gold: gold, rewards: nil, adventuring?: false)
    }
  end

  @impl true
  def handle_event("go_adventure", _params, socket) do
    user_id = socket.assigns.current_scope.users.id

    socket =
      socket
      |> assign(adventuring?: true, rewards: nil)

    case Adventures.complete_adventure(user_id) do
      {:ok, rewards} ->
        gold = Game.get_user_gold(user_id)

        {:noreply,
         socket
         |> assign(gold: gold, rewards: rewards, adventuring?: false)
         |> put_flash(:info, "Adventure completed!")}

      {:error, _reason} ->
        {:noreply,
         socket
         |> assign(adventuring?: false)
         |> put_flash(:error, "Failed to complete adventure")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="space-y-8">
        <.header>
          Adventure
          <:subtitle>Explore the unknown and earn rewards</:subtitle>
        </.header>

        <div class="max-w-2xl mx-auto">
          <div class="card bg-base-100 shadow-xl">
            <div class="card-body">
              <div class="flex justify-between items-center mb-4">
                <h2 class="card-title">Your Gold</h2>
                <div class="text-2xl font-bold text-primary">{@gold}</div>
              </div>

              <div class="divider"></div>

              <%= if @adventuring? do %>
                <div class="text-center py-8">
                  <span class="loading loading-spinner loading-lg"></span>
                  <p class="mt-4">Embarking on adventure...</p>
                </div>
              <% else %>
                <div class="text-center">
                  <.button
                    phx-click="go_adventure"
                    id="adventure-button"
                    class="btn-primary btn-lg"
                  >
                    <.icon name="hero-map" class="w-6 h-6 mr-2" />
                    Go on Adventure
                  </.button>
                </div>
              <% end %>

              <%= if @rewards do %>
                <div class="divider"></div>
                <div class="space-y-4">
                  <h3 class="text-lg font-semibold">Rewards Earned:</h3>

                  <div class="alert alert-success">
                    <.icon name="hero-currency-dollar" class="w-6 h-6" />
                    <span>Gold: {@rewards.gold}</span>
                  </div>

                  <%= if length(@rewards.loot_items) > 0 do %>
                    <div class="alert alert-info">
                      <.icon name="hero-gift" class="w-6 h-6" />
                      <div>
                        <p class="font-semibold">Loot Items:</p>
                        <ul class="list-disc list-inside">
                          <%= for item <- @rewards.loot_items do %>
                            <li>{item.name}</li>
                          <% end %>
                        </ul>
                      </div>
                    </div>
                  <% end %>

                  <%= if length(@rewards.sellable_items) > 0 do %>
                    <div class="alert alert-warning">
                      <.icon name="hero-shopping-bag" class="w-6 h-6" />
                      <div>
                        <p class="font-semibold">Sellable Items:</p>
                        <ul class="list-disc list-inside">
                          <%= for item <- @rewards.sellable_items do %>
                            <li>{item.name}</li>
                          <% end %>
                        </ul>
                      </div>
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
