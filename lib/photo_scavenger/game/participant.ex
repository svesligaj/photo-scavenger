defmodule PhotoScavenger.Game.Participant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "participants" do
    field :name, :string
    field :token, :string
    has_many :assignments, PhotoScavenger.Game.Assignment
    has_many :photos, PhotoScavenger.Game.Photo

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(participant, attrs) do
    participant
    |> cast(attrs, [:name, :token])
    |> validate_required([:name, :token])
    |> unique_constraint(:token)
  end
end
