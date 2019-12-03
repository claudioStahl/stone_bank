defmodule StoneBank.Accounts.AccountCallbacks do
  alias StoneBank.Accounts.Account

  @callback after_insert(%Account{}) :: term

  @gift_value Application.get_env(:stone_bank, :gift_value)
  @gift_transaction_factory Application.get_env(:stone_bank, :gift_transaction_factory)

  def after_insert(account) do
    {:ok, _transaction} = @gift_transaction_factory.call(account.id, @gift_value)
  end
end
