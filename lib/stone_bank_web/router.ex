defmodule StoneBankWeb.Router do
  use StoneBankWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", StoneBankWeb do
    pipe_through :api

    resources "/accounts", AccountController, only: [:create]
    resources "/auth", AuthController, only: [:create]
  end
end
