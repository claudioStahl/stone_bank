defmodule StoneBank.Accounts.TransactionNotificators.DefaultNotificator do
  require Logger

  @behaviour StoneBank.Accounts.TransactionNotificators.Behaviour

  def notify_success!(transaction) do
    Logger.warn("Notify success to transaction ##{transaction.id}")
  end

  def notify_fail!(transaction) do
    Logger.warn("Notify fail to transaction ##{transaction.id}")
  end
end
