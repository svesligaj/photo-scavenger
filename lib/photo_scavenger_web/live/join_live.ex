defmodule PhotoScavengerWeb.JoinLive do
  use PhotoScavengerWeb, :live_view

  alias PhotoScavenger.Game

  def mount(_params, _session, socket) do
    {:ok, assign(socket, name: "", error: nil, locale: "en")}
  end

  def handle_event("validate", %{"name" => name, "locale" => locale}, socket) do
    {:noreply, assign(socket, name: String.trim(name), locale: locale)}
  end

  def handle_event("submit", %{"name" => name, "locale" => locale}, socket) do
    name = String.trim(name)

    if name == "" do
      {:noreply, assign(socket, error: "Please enter your name")}
    else
      participant = Game.create_participant_with_token!(name)
      tasks = Game.random_tasks(5)
      Game.assign_tasks_to_participant!(participant, tasks)
      {:noreply, push_navigate(socket, to: ~p"/hunt/#{participant.token}?lang=#{locale}")}
    end
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="join-page max-w-md mx-auto p-6">
        <h1 class="text-2xl font-bold mb-4">Photo Scavenger Hunt</h1>
        <form method="post" phx-change="validate" phx-submit="submit" class="grid gap-3">
          <input type="text" name="name" value={@name} placeholder="Your name" class="border p-2 rounded" />
          <div class="flex gap-4">
            <label class="flex items-center gap-2">
              <input type="radio" name="locale" value="en" checked={@locale == "en"} /> EN
            </label>
            <label class="flex items-center gap-2">
              <input type="radio" name="locale" value="hr" checked={@locale == "hr"} /> HR
            </label>
          </div>
          <%= if @error do %>
            <p class="text-red-600"><%= @error %></p>
          <% end %>
          <button type="submit" class="btn">Start</button>
        </form>
      </div>
    </Layouts.app>
    """
  end
end
