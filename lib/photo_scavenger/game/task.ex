defmodule PhotoScavenger.Game.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :content_en, :string
    field :content_hr, :string
    field :active, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:content_en, :content_hr, :active])
    |> validate_required([:content_en, :content_hr, :active])
  end
end
