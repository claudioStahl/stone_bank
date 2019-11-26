defmodule StoneBankWeb.Router do
  use StoneBankWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", StoneBankWeb do
    pipe_through :api
  end
end
