defmodule PhotoScavenger.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PhotoScavengerWeb.Telemetry,
      PhotoScavenger.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:photo_scavenger, :ecto_repos), skip: skip_migrations?()},
      {Phoenix.PubSub, name: PhotoScavenger.PubSub},
      # Start a worker by calling: PhotoScavenger.Worker.start_link(arg)
      # {PhotoScavenger.Worker, arg},
      # Start to serve requests, typically the last entry
      PhotoScavengerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhotoScavenger.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhotoScavengerWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    System.get_env("RELEASE_NAME") == nil
  end
end
