defmodule StoneBankWeb.TransferenceController do
  use StoneBankWeb, :controller

  alias StoneBank.Accounts.Transaction

  action_fallback StoneBankWeb.FallbackController

  @transference_transaction_factory Application.get_env(
                                      :stone_bank,
                                      :transference_transaction_factory
                                    )

  def create(%Plug.Conn{assigns: %{signed_account_id: signed_account_id}} = conn, %{
        "value" => value,
        "destination_account_number" => destination_account_number
      }) do
    with {:ok, {%Transaction{} = outbound_transaction, _}} <-
           @transference_transaction_factory.call(
             signed_account_id,
             destination_account_number,
             value
           ) do
      conn
      |> put_status(:created)
      |> put_view(StoneBankWeb.TransactionView)
      |> render("show.json", transaction: outbound_transaction)
    else
      {:error, :destination_account_not_found} ->
        {:unprocessable_entity, gettext("Destination account not found")}

      {:error, :unavailable_limit} ->
        {:unprocessable_entity, gettext("Unavailable limit")}

      error ->
        error
    end
  end

  def create(_, _) do
    {:bad_request, gettext("Fill all attributes")}
  end
end
