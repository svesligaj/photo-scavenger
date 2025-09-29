defmodule PhotoScavenger.Repo.Migrations.AddUniqueIndexOnTasksContent do
  use Ecto.Migration

  def change do
    create unique_index(:tasks, [:content_en, :content_hr])
  end
end
