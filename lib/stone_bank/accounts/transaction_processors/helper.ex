defmodule StoneBank.Accounts.TransactionProcessors.Helper do
  alias StoneBank.Repo
  alias StoneBank.Accounts.Account
  alias StoneBank.Accounts.Transaction

  def mark_processed!(transaction) do
    transaction
    |> Transaction.mark_processed()
    |> Repo.update!()
  end

  def mark_processed_with_error!(transaction, error) do
    transaction
    |> Transaction.mark_processed()
    |> Transaction.add_error(error)
    |> Repo.update!()
  end

  def apply_inbound!(%Account{} = account, value) do
    account
    |> Account.apply_inbound(value)
    |> Repo.update!()
  end

  def apply_outbound!(%Account{} = account, value) do
    account
    |> Account.apply_outbound(value)
    |> Repo.update!()
  end
end
