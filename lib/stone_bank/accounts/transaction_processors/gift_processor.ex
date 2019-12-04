defmodule StoneBank.Accounts.TransactionProcessors.GiftProcessor do
  import Ecto.Query, warn: false
  import StoneBank.Accounts.TransactionProcessors.Helper

  alias StoneBank.Repo
  alias StoneBank.Accounts.Account
  alias StoneBank.Accounts.Transaction

  @behaviour StoneBank.Accounts.TransactionProcessors.Behaviour

  def call(%Transaction{account_id: account_id, value: value} = transaction, notificator) do
    account = Repo.get!(Account, account_id)
    apply_inbound!(account, value)
    mark_processed!(transaction)
    notificator.notify_success!(transaction)
  end
end
