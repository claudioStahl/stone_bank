defmodule StoneBankWeb.AuthController do
  use StoneBankWeb, :controller

  alias StoneBank.Accounts.Account

  action_fallback StoneBankWeb.FallbackController

  @user_salt Application.get_env(:stone_bank, :user_salt)
  @accounts Application.get_env(:stone_bank, :accounts_module)

  def create(conn, %{"number" => number, "password" => password}) do
    with {:ok, %Account{} = account} <-
           @accounts.get_account_by_number_and_password(number, password) do
      token = Phoenix.Token.sign(StoneBankWeb.Endpoint, @user_salt, account.id)

      conn
      |> put_status(:ok)
      |> render("show.json", token: token)
    else
      {:error, :not_found} -> {:unauthorized, gettext("Number or password invalids")}
    end
  end
end
