defmodule PhotoScavenger.Repo.Migrations.CreateAssignments do
  use Ecto.Migration

  def change do
    create table(:assignments) do
      add :participant_id, references(:participants, on_delete: :nothing)
      add :task_id, references(:tasks, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:assignments, [:participant_id])
    create index(:assignments, [:task_id])
  end
end
