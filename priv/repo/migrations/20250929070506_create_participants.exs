defmodule PhotoScavenger.Repo.Migrations.CreateParticipants do
  use Ecto.Migration

  def change do
    create table(:participants) do
      add :name, :string
      add :token, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:participants, [:token])
  end
end
