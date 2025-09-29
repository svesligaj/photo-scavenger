defmodule PhotoScavengerWeb.Router do
  use PhotoScavengerWeb, :router

  import Phoenix.LiveView.Router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PhotoScavengerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/api", PhotoScavengerWeb do
    pipe_through :api
  end

  scope "/", PhotoScavengerWeb do
    pipe_through :browser

    live "/", JoinLive, :index
    live "/hunt/:token", HuntLive, :show
    live "/admin/review", Admin.ReviewLive, :index
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:photo_scavenger, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: PhotoScavengerWeb.Telemetry
    end
  end
end
