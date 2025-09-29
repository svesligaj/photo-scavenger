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
        <div class="mb-6">
          <button phx-click="purge_all" data-confirm="Are you sure?" class="btn bg-red-600 text-white px-3 py-2 rounded">Purge ALL test data</button>
        </div>
        <div class="space-y-8">
          <%= for p <- @participants do %>
            <section class="border rounded p-4">
              <h3 class="text-xl font-semibold"><%= p.name %></h3>
              <p class="text-sm text-gray-600">Token: <%= p.token %></p>
              <div class="mt-2">
                <button phx-click="delete_participant" phx-value-id={p.id} data-confirm="Delete this participant and all data?" class="text-sm text-red-700 underline">Delete participant</button>
              </div>
              <div class="grid md:grid-cols-2 gap-6 mt-4">
                <div>
                  <h4 class="font-medium mb-2">Assigned tasks</h4>
                  <ol class="list-decimal ml-5 space-y-1">
                    <%= for {a, index} <- Enum.with_index(p.assignments, 1) do %>
                      <li class="flex items-center justify-between">
                        <div class="flex items-center gap-2">
                          <span class="bg-blue-100 text-blue-800 text-xs font-medium px-2 py-1 rounded">Task <%= index %></span>
                          <span><%= a.task.content_en %> / <%= a.task.content_hr %></span>
                        </div>
                        <%= if Enum.any?(p.photos, &(&1.task_id == a.task.id)) do %>
                          <span class="text-green-600 text-sm">✓ Photo uploaded</span>
                        <% end %>
                      </li>
                    <% end %>
                  </ol>
                </div>
                <div>
                  <h4 class="font-medium mb-2">Photos</h4>
                  <div class="grid grid-cols-2 gap-3">
                    <%= for {ph, index} <- Enum.with_index(p.photos, 1) do %>
                      <div class="relative">
                        <a href={ph.file_path} target="_blank" class="block">
                          <img src={ph.file_path} class="w-full h-32 object-cover rounded" />
                        </a>
                        <div class="absolute top-1 left-1 bg-black bg-opacity-70 text-white text-xs px-1 rounded">
                          Task <%= Enum.find_index(p.assignments, &(&1.task_id == ph.task_id)) + 1 %>
                        </div>
                      </div>
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

  def handle_event("purge_all", _params, socket) do
    # Delete all photos from database first to get file paths
    photos = Repo.all(Photo)

    # Delete from database
    Repo.delete_all(Photo)
    Repo.delete_all(Assignment)
    Repo.delete_all(Participant)

    # Delete uploaded files from filesystem
    for photo <- photos do
      file_path = Path.join([to_string(:code.priv_dir(:photo_scavenger)), "static", String.trim_leading(photo.file_path, "/")])
      if File.exists?(file_path) do
        File.rm(file_path)
      end
    end

    # Remove uploads directory
    uploads_dir = Path.join([to_string(:code.priv_dir(:photo_scavenger)), "static", "uploads"])
    if File.exists?(uploads_dir) do
      File.rm_rf!(uploads_dir)
    end

    {:noreply, assign(socket, participants: list_participants())}
  end

  def handle_event("delete_participant", %{"id" => id}, socket) do
    participant = Repo.get!(Participant, id)
    PhotoScavenger.Game.delete_participant_data(participant)
    {:noreply, assign(socket, participants: list_participants())}
  end
end
