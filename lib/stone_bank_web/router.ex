defmodule StoneBankWeb.Router do
  use StoneBankWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated_api do
    plug :accepts, ["json"]
    plug StoneBankWeb.Plugs.Authenticate
  end

  scope "/api/v1", StoneBankWeb do
    pipe_through :api

    resources "/accounts", AccountController, only: [:create]
    resources "/auth", AuthController, only: [:create]
  end

  scope "/api/v1/me", StoneBankWeb do
    pipe_through :authenticated_api

    resources "/withdrawals", WithdrawalController, only: [:create]
    resources "/transferences", TransferenceController, only: [:create]
  end
end
