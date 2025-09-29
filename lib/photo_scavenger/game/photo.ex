defmodule PhotoScavenger.Game.Photo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "photos" do
    field :file_path, :string
    field :content_type, :string
    field :byte_size, :integer
    belongs_to :participant, PhotoScavenger.Game.Participant
    belongs_to :task, PhotoScavenger.Game.Task

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(photo, attrs) do
    photo
    |> cast(attrs, [:file_path, :content_type, :byte_size, :participant_id, :task_id])
    |> validate_required([:file_path, :content_type, :byte_size, :participant_id, :task_id])
  end
end
