defmodule PhotoScavenger.Repo.Migrations.CreatePhotos do
  use Ecto.Migration

  def change do
    create table(:photos) do
      add :file_path, :string
      add :content_type, :string
      add :byte_size, :integer
      add :participant_id, references(:participants, on_delete: :nothing)
      add :task_id, references(:tasks, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:photos, [:participant_id])
    create index(:photos, [:task_id])
  end
end
