defmodule StoneBank.Accounts.TransactionFactories.WithdrawalFactory do
  import StoneBank.ChangesetHelper

  alias StoneBank.Repo
  alias StoneBank.Accounts.Account
  alias StoneBank.Accounts.Transaction

  @doc """
  Creates a transaction to withdraw.

  ## Examples

      iex> add_withdrawal_transaction(account_id, value)
      {:ok, %Transaction{}}

      iex> add_withdrawal_transaction(bad_value, bad_value)
      {:error, %Ecto.Changeset{}}

  """
  def call(account_id, value) do
    account = Repo.get!(Account, account_id)
    changeset = build_changeset(account_id, value)

    with {:ok, changeset} <- check_changeset(changeset),
         {:ok, _account} <- Account.check_available_limit(account, value) do
      transaction = Repo.insert!(changeset)
      {:ok, transaction}
    end
  end

  defp build_changeset(account_id, value) do
    Transaction.changeset(%Transaction{}, %{
      account_id: account_id,
      value: value,
      action: "withdrawal",
      kind: "outbound"
    })
  end
end
