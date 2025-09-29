defmodule PhotoScavenger.Game.Assignment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "assignments" do
    belongs_to :participant, PhotoScavenger.Game.Participant
    belongs_to :task, PhotoScavenger.Game.Task

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(assignment, attrs) do
    assignment
    |> cast(attrs, [:participant_id, :task_id])
    |> validate_required([:participant_id, :task_id])
  end
end
