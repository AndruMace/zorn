defmodule ZornWeb.HomeLive do
  use ZornWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("navigate", %{"destination" => destination}, socket) do
    {:noreply, push_navigate(socket, to: destination)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="space-y-12">
        <.header>
          Home
          <:subtitle>Choose your path and begin your adventure</:subtitle>
        </.header>

        <div id="home-actions" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 max-w-5xl mx-auto">
          <div class="card bg-base-100 border-2 border-base-300 hover:border-primary transition-all duration-200 hover:shadow-lg">
            <div class="card-body items-center text-center p-6">
              <.icon name="hero-fire" class="size-12 text-primary mb-2" />
              <h2 class="card-title text-xl mb-2">Blacksmith</h2>
              <p class="text-sm text-base-content/70 mb-4">Forge weapons and armor</p>
              <.button
                id="blacksmith-btn"
                phx-click="navigate"
                phx-value-destination={~p"/blacksmith"}
                class="btn-primary btn-block"
              >
                Enter
              </.button>
            </div>
          </div>

          <div class="card bg-base-100 border-2 border-base-300 hover:border-primary transition-all duration-200 hover:shadow-lg">
            <div class="card-body items-center text-center p-6">
              <.icon name="hero-shopping-bag" class="size-12 text-primary mb-2" />
              <h2 class="card-title text-xl mb-2">Merchant</h2>
              <p class="text-sm text-base-content/70 mb-4">Buy and sell goods</p>
              <.button
                id="merchant-btn"
                phx-click="navigate"
                phx-value-destination={~p"/merchant"}
                class="btn-primary btn-block"
              >
                Enter
              </.button>
            </div>
          </div>

          <div class="card bg-base-100 border-2 border-base-300 hover:border-primary transition-all duration-200 hover:shadow-lg">
            <div class="card-body items-center text-center p-6">
              <.icon name="hero-map" class="size-12 text-primary mb-2" />
              <h2 class="card-title text-xl mb-2">Adventure</h2>
              <p class="text-sm text-base-content/70 mb-4">Explore the unknown</p>
              <.button
                id="adventure-btn"
                phx-click="navigate"
                phx-value-destination={~p"/adventure"}
                class="btn-primary btn-block"
              >
                Enter
              </.button>
            </div>
          </div>

          <div class="card bg-base-100 border-2 border-base-300 hover:border-primary transition-all duration-200 hover:shadow-lg">
            <div class="card-body items-center text-center p-6">
              <.icon name="hero-academic-cap" class="size-12 text-primary mb-2" />
              <h2 class="card-title text-xl mb-2">Train</h2>
              <p class="text-sm text-base-content/70 mb-4">Improve your skills</p>
              <.button id="train-btn" class="btn-primary btn-block">
                Enter
              </.button>
            </div>
          </div>

          <div class="card bg-base-100 border-2 border-base-300 hover:border-primary transition-all duration-200 hover:shadow-lg">
            <div class="card-body items-center text-center p-6">
              <.icon name="hero-building-storefront" class="size-12 text-primary mb-2" />
              <h2 class="card-title text-xl mb-2">Market</h2>
              <p class="text-sm text-base-content/70 mb-4">Trade with others</p>
              <.button id="market-btn" class="btn-primary btn-block">
                Enter
              </.button>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
