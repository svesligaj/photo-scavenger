defmodule PhotoScavengerWeb.HuntLive do
  use PhotoScavengerWeb, :live_view

  alias PhotoScavenger.Game
  alias PhotoScavenger.Game.Task

  def mount(%{"token" => token, "lang" => lang} = _params, _session, socket) do
    case Game.get_participant_by_token(token) do
      nil -> {:ok, redirect(socket, to: ~p"/")}
      participant ->
        assignments = Game.list_assignments_for_participant(participant)
        completed = Game.list_photo_task_ids_for_participant(participant)
        socket = allow_upload(socket, :photo, accept: ~w(.jpg .jpeg .png .heic .webp), max_entries: 1)
        {:ok, assign(socket, participant: participant, assignments: assignments, completed: completed, lang: lang || "en", uploading_task_id: nil)}
    end
  end

  def handle_event("select-task", %{"task-id" => id}, socket) do
    {:noreply, assign(socket, uploading_task_id: String.to_integer(id))}
  end

  def handle_event("cancel-upload", _params, socket) do
    {:noreply, assign(socket, uploading_task_id: nil)}
  end

  def handle_event("save", _params, %{assigns: %{participant: p, uploading_task_id: tid}} = socket) when not is_nil(tid) do
    consume_uploaded_entries(socket, :photo, fn %{path: path}, entry ->
      Game.save_photo_upload!(p, %Task{id: tid}, %{path: path, content_type: entry.client_type, filename: entry.client_name})
      {:ok, path}
    end)

    completed = MapSet.put(socket.assigns.completed, tid)
    {:noreply, assign(socket, uploading_task_id: nil, completed: completed)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="hunt-page max-w-2xl mx-auto p-6">
        <h2 class="text-xl font-semibold mb-4">Your tasks</h2>

        <div class="grid gap-4">
          <%= for a <- @assignments do %>
            <div class="p-4 border rounded">
              <p class="mb-2 flex items-center justify-between gap-3">
                <%= if @lang == "hr" do %>
                  <%= a.task.content_hr %>
                <% else %>
                  <%= a.task.content_en %>
                <% end %>
                <%= if MapSet.member?(@completed, a.task.id) do %>
                  <span class="inline-block text-green-600" aria-label="completed">✓</span>
                <% end %>
              </p>
              <button phx-click="select-task" phx-value-task-id={a.task.id} class="btn">Upload photo</button>

              <%= if @uploading_task_id == a.task.id do %>
                <div class="mt-3">
                  <form phx-submit="save">
                    <.live_file_input upload={@uploads.photo} />
                    <div class="flex gap-2 mt-2">
                      <button type="submit" class="btn">Save</button>
                      <button type="button" class="btn" phx-click="cancel-upload">Cancel</button>
                    </div>
                  </form>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
