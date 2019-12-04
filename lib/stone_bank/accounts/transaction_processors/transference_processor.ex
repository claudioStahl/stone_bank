defmodule StoneBank.Accounts.TransactionProcessors.TransferenceProcessor do
  import Ecto.Query, warn: false
  import StoneBank.Accounts.TransactionProcessors.Helper

  alias StoneBank.Repo
  alias StoneBank.Accounts.Account
  alias StoneBank.Accounts.Transaction

  @behaviour StoneBank.Accounts.TransactionProcessors.Behaviour

  def call(%Transaction{group_id: group_id}, notificator) do
    outbound_transaction = Repo.get_by!(Transaction, group_id: group_id, kind: "outbound")
    inbound_transaction = Repo.get_by!(Transaction, group_id: group_id, kind: "inbound")
    outbound_account = Repo.get!(Account, outbound_transaction.account_id)
    inbound_account = Repo.get!(Account, inbound_transaction.account_id)

    case Account.check_available_limit(outbound_account, outbound_transaction.value) do
      {:ok, outbound_account} ->
        apply_success(
          outbound_account,
          inbound_account,
          outbound_transaction,
          inbound_transaction,
          notificator
        )

      {:error, :unavailable_limit} ->
        apply_fail(outbound_transaction, inbound_transaction, notificator)
    end
  end

  defp apply_success(
         outbound_account,
         inbound_account,
         outbound_transaction,
         inbound_transaction,
         notificator
       ) do
    apply_outbound!(outbound_account, outbound_transaction.value)
    apply_inbound!(inbound_account, inbound_transaction.value)

    mark_processed!(outbound_transaction)
    mark_processed!(inbound_transaction)

    notificator.notify_success!(outbound_transaction)
  end

  defp apply_fail(outbound_transaction, inbound_transaction, notificator) do
    mark_processed_with_error!(outbound_transaction, "unavailable_limit")
    mark_processed_with_error!(inbound_transaction, "unavailable_limit")

    notificator.notify_fail!(outbound_transaction)
  end
end
