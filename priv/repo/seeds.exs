alias PhotoScavenger.Repo
alias PhotoScavenger.Game.Task

# Seed bilingual tasks
# Safe to run multiple times; will upsert by content_en/content_hr pairs

tasks = [
  {"Take a photo of the bride dancing", "Slikaj mladenku kako pleše"},
  {"Take a photo of the best man drinking", "Slikaj kuma kako pije"},
  {"Take a photo of the oldest and youngest person at your table", "Slikaj najstariju i najmlađu osobu za vašim stolom"},
  {"Take a photo of two people hugging", "Slikaj dvoje ljudi kako se grle"},
  {"Take a photo of a group cheering", "Slikaj grupu kako nazdravlja"},
  {"Take a photo of the wedding cake", "Slikaj svadbenu tortu"},
  {"Take a photo of someone dancing solo", "Slikaj nekoga tko pleše solo"},
  {"Take a photo of a funny face", "Slikaj smiješno lice"},
  {"Take a photo of a toast", "Slikaj zdravicu"},
  {"Take a photo of the bouquet", "Slikaj buket"}
]

for {en, hr} <- tasks do
  %Task{content_en: en, content_hr: hr, active: true}
  |> Task.changeset(%{})
  |> Repo.insert!(on_conflict: :nothing, conflict_target: [:content_en, :content_hr])
end
