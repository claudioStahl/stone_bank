defmodule StoneBankWeb.AccountController do
  use StoneBankWeb, :controller

  alias StoneBank.Accounts.Account

  action_fallback StoneBankWeb.FallbackController

  @accounts Application.get_env(:stone_bank, :accounts_module)

  def create(conn, %{"name" => name, "password" => password}) do
    with {:ok, %Account{} = account} <- @accounts.create_account(name, password) do
      conn
      |> put_status(:created)
      |> render("show.json", account: account)
    end
  end

  def create(_, _) do
    {:bad_request, gettext("Fill all attributes")}
  end
end
