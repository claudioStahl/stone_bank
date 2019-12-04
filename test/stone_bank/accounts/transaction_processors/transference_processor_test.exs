defmodule StoneBank.Accounts.TransactionProcessors.TransferenceProcessorTest do
  use StoneBank.DataCase, async: true

  import Mox
  import StoneBank.Fixtures.Accounts

  alias Ecto.UUID
  alias StoneBank.Repo
  alias StoneBank.TimeMock
  alias StoneBank.Accounts.Account
  alias StoneBank.Accounts.Transaction
  alias StoneBank.Accounts.TransactionProcessors.TransferenceProcessor
  alias StoneBank.Accounts.TransactionNotificators.NotificatorMock

  @naive_date_time ~N[2019-12-03 13:10:01]

  setup :verify_on_exit!

  describe "call/2" do
    test "successfully" do
      expect(TimeMock, :naive_date_time_utc_now, 2, fn -> @naive_date_time end)
      expect(NotificatorMock, :notify_success!, fn %Transaction{} -> nil end)

      group_id = UUID.generate()
      outbound_account = fixture!(:account, total: 10)
      inbound_account = fixture!(:account, total: 10)

      outbound_transaction =
        fixture!(:transaction,
          value: 2,
          account_id: outbound_account.id,
          group_id: group_id,
          kind: "outbound"
        )

      inbound_transaction =
        fixture!(:transaction,
          value: 2,
          account_id: inbound_account.id,
          group_id: group_id,
          kind: "inbound"
        )

      TransferenceProcessor.call(outbound_transaction, NotificatorMock)

      outbound_transaction = Repo.get!(Transaction, outbound_transaction.id)
      inbound_transaction = Repo.get!(Transaction, inbound_transaction.id)
      outbound_account = Repo.get!(Account, outbound_account.id)
      inbound_account = Repo.get!(Account, inbound_account.id)

      assert outbound_transaction.processed_at == @naive_date_time
      assert inbound_transaction.processed_at == @naive_date_time
      assert outbound_account.total == 8
      assert inbound_account.total == 12
    end

    test "fails because of unavailable limit" do
      expect(TimeMock, :naive_date_time_utc_now, 2, fn -> @naive_date_time end)
      expect(NotificatorMock, :notify_fail!, fn %Transaction{} -> nil end)

      group_id = UUID.generate()
      outbound_account = fixture!(:account, total: 1)
      inbound_account = fixture!(:account, total: 1)

      outbound_transaction =
        fixture!(:transaction,
          value: 2,
          account_id: outbound_account.id,
          group_id: group_id,
          kind: "outbound"
        )

      inbound_transaction =
        fixture!(:transaction,
          value: 2,
          account_id: inbound_account.id,
          group_id: group_id,
          kind: "inbound"
        )

      TransferenceProcessor.call(outbound_transaction, NotificatorMock)

      outbound_transaction = Repo.get!(Transaction, outbound_transaction.id)
      inbound_transaction = Repo.get!(Transaction, inbound_transaction.id)
      outbound_account = Repo.get!(Account, outbound_account.id)
      inbound_account = Repo.get!(Account, inbound_account.id)

      assert outbound_transaction.processed_at == @naive_date_time
      assert inbound_transaction.processed_at == @naive_date_time
      assert outbound_transaction.error == "unavailable_limit"
      assert inbound_transaction.error == "unavailable_limit"
      assert outbound_account.total == 1
      assert inbound_account.total == 1
    end
  end
end
