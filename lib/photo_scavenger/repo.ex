defmodule PhotoScavenger.Repo do
  use Ecto.Repo,
    otp_app: :photo_scavenger,
    adapter: Ecto.Adapters.Postgres
end
