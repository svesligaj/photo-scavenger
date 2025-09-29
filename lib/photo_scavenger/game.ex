defmodule PhotoScavenger.Game do
  @moduledoc """
  Game context for participants, tasks, assignments, and photos.
  """

  import Ecto.Query, warn: false
  alias PhotoScavenger.Repo

  alias PhotoScavenger.Game.{Participant, Task, Assignment, Photo}

  def generate_token() do
    :crypto.strong_rand_bytes(8) |> Base.url_encode64(padding: false)
  end

  def create_participant_with_token!(name) do
    token = generate_token()
    %Participant{} |> Participant.changeset(%{name: name, token: token}) |> Repo.insert!()
  end

  def get_participant_by_token(token), do: Repo.get_by(Participant, token: token)

  def random_tasks(limit) when is_integer(limit) and limit > 0 do
    from(t in Task, where: t.active == true, order_by: fragment("RANDOM()"), limit: ^limit)
    |> Repo.all()
  end

  def assign_tasks_to_participant!(%Participant{id: participant_id}, tasks) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    entries = Enum.map(tasks, fn %Task{id: task_id} -> %{participant_id: participant_id, task_id: task_id, inserted_at: now, updated_at: now} end)
    Repo.insert_all(Assignment, entries, on_conflict: :nothing)
  end

  def list_assignments_for_participant(%Participant{id: participant_id}) do
    query =
      from a in Assignment,
        where: a.participant_id == ^participant_id,
        join: t in Task, on: t.id == a.task_id,
        preload: [task: t]

    Repo.all(query)
  end

  def list_photo_task_ids_for_participant(%Participant{id: participant_id}) do
    from(p in Photo, where: p.participant_id == ^participant_id, select: p.task_id)
    |> Repo.all()
    |> MapSet.new()
  end

  def save_photo_upload!(%Participant{id: pid}, %Task{id: tid}, %{path: path, content_type: ct, filename: filename}) do
    uploads_dir = Path.join([to_string(:code.priv_dir(:photo_scavenger)), "static", "uploads", Integer.to_string(pid)])
    File.mkdir_p!(uploads_dir)
    dest = Path.join(uploads_dir, unique_filename(filename))
    File.cp!(path, dest)

    rel_path = Path.relative_to(dest, Path.join([to_string(:code.priv_dir(:photo_scavenger)), "static"]))

    %Photo{}
    |> Photo.changeset(%{
      file_path: "/" <> rel_path,
      content_type: ct,
      byte_size: File.stat!(dest).size,
      participant_id: pid,
      task_id: tid
    })
    |> Repo.insert!()
  end

  def delete_participant_data(participant) do
    Repo.transaction(fn ->
      # Delete photos from database first to get file paths
      photos = Repo.all(from p in Photo, where: p.participant_id == ^participant.id)

      # Delete photos from database
      Repo.delete_all(from p in Photo, where: p.participant_id == ^participant.id)

      # Delete assignments
      Repo.delete_all(from a in Assignment, where: a.participant_id == ^participant.id)

      # Delete participant
      Repo.delete(participant)

      # Delete uploaded files from filesystem
      for photo <- photos do
        file_path = Path.join([to_string(:code.priv_dir(:photo_scavenger)), "static", String.trim_leading(photo.file_path, "/")])
        if File.exists?(file_path) do
          File.rm(file_path)
        end
      end

      # Remove participant's upload directory if it exists and is empty
      uploads_dir = Path.join([to_string(:code.priv_dir(:photo_scavenger)), "static", "uploads", Integer.to_string(participant.id)])
      if File.exists?(uploads_dir) do
        case File.rmdir(uploads_dir) do
          :ok -> :ok
          {:error, :enotempty} -> :ok  # Directory not empty, that's fine
          {:error, _} -> :ok  # Other errors, ignore
        end
      end
    end)
  end

  defp unique_filename(filename) do
    base = :erlang.unique_integer([:positive]) |> Integer.to_string()
    ext = Path.extname(filename)
    base <> ext
  end
end
