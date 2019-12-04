defmodule StoneBank.Accounts.TransactionProcessors.Behaviour do
  alias StoneBank.Accounts.Transaction
  alias StoneBank.Accounts.TransactionNotificators.Behaviour

  @callback call(%Transaction{}, Behaviour.t()) :: term
end
