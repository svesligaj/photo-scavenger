defmodule PhotoScavengerWeb.Admin.ReviewLive do
  use PhotoScavengerWeb, :live_view

  import Ecto.Query
  alias PhotoScavenger.Repo
  alias PhotoScavenger.Game.{Participant, Assignment, Task, Photo}

  def mount(_params, _session, socket) do
    {:ok, assign(socket, participants: list_participants())}
  end

  defp list_participants() do
    Repo.all(
      from p in Participant,
        order_by: [asc: p.inserted_at],
        preload: [
          assignments: ^from(a in Assignment, join: t in Task, on: t.id == a.task_id, preload: [task: t]),
          photos: ^from(ph in Photo, order_by: [asc: ph.inserted_at])
        ]
    )
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="admin-review max-w-5xl mx-auto p-6">
        <h2 class="text-2xl font-bold mb-4">Admin Review</h2>
        <div class="space-y-8">
          <%= for p <- @participants do %>
            <section class="border rounded p-4">
              <h3 class="text-xl font-semibold"><%= p.name %></h3>
              <p class="text-sm text-gray-600">Token: <%= p.token %></p>
              <div class="grid md:grid-cols-2 gap-6 mt-4">
                <div>
                  <h4 class="font-medium mb-2">Assigned tasks</h4>
                  <ul class="list-disc ml-5 space-y-1">
                    <%= for a <- p.assignments do %>
                      <li><%= a.task.content_en %> / <%= a.task.content_hr %></li>
                    <% end %>
                  </ul>
                </div>
                <div>
                  <h4 class="font-medium mb-2">Photos</h4>
                  <div class="grid grid-cols-2 gap-3">
                    <%= for ph <- p.photos do %>
                      <a href={ph.file_path} target="_blank" class="block">
                        <img src={ph.file_path} class="w-full h-32 object-cover rounded" />
                      </a>
                    <% end %>
                  </div>
                </div>
              </div>
            </section>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
