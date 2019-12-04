defmodule StoneBank.Accounts.TransactionProcessors.WithdrawalProcessor do
  import Ecto.Query, warn: false
  import StoneBank.Accounts.TransactionProcessors.Helper

  alias StoneBank.Repo
  alias StoneBank.Accounts.Account
  alias StoneBank.Accounts.Transaction

  @behaviour StoneBank.Accounts.TransactionProcessors.Behaviour

  def call(%Transaction{account_id: account_id, value: value} = transaction, notificator) do
    account = Repo.get!(Account, account_id)

    case Account.check_available_limit(account, value) do
      {:ok, account} ->
        apply_outbound!(account, value)
        mark_processed!(transaction)
        notificator.notify_success!(transaction)

      {:error, :unavailable_limit} ->
        mark_processed_with_error!(transaction, "unavailable_limit")
        notificator.notify_fail!(transaction)
    end
  end
end
