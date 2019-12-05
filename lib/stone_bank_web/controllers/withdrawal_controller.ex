defmodule StoneBankWeb.WithdrawalController do
  use StoneBankWeb, :controller

  alias StoneBank.Accounts.Transaction

  action_fallback StoneBankWeb.FallbackController

  @withdrawal_transaction_factory Application.get_env(
                                    :stone_bank,
                                    :withdrawal_transaction_factory
                                  )

  def create(%Plug.Conn{assigns: %{signed_account_id: signed_account_id}} = conn, %{
        "value" => value
      }) do
    with {:ok, %Transaction{} = transaction} <-
           @withdrawal_transaction_factory.call(signed_account_id, value) do
      conn
      |> put_status(:created)
      |> put_view(StoneBankWeb.TransactionView)
      |> render("show.json", transaction: transaction)
    else
      {:error, :unavailable_limit} -> {:unprocessable_entity, gettext("Unavailable limit")}
      error -> error
    end
  end

  def create(_, _) do
    {:bad_request, gettext("Fill all attributes")}
  end
end
