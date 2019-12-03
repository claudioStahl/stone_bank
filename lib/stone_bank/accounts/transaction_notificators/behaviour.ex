defmodule StoneBank.Accounts.TransactionNotificators.Behaviour do
  alias StoneBank.Accounts.Transaction

  @callback notify_success!(%Transaction{}) :: term
  @callback notify_fail!(%Transaction{}) :: term
end
