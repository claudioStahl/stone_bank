defmodule StoneBank.Accounts.TransactionProcessors.GiftProcessorTest do
  use StoneBank.DataCase, async: true

  import Mox
  import StoneBank.Fixtures.Accounts

  alias StoneBank.Repo
  alias StoneBank.TimeMock
  alias StoneBank.Accounts.Account
  alias StoneBank.Accounts.Transaction
  alias StoneBank.Accounts.TransactionProcessors.GiftProcessor
  alias StoneBank.Accounts.TransactionNotificators.NotificatorMock

  @naive_date_time ~N[2019-12-03 13:10:01]

  setup :verify_on_exit!

  def mock do
    expect(TimeMock, :naive_date_time_utc_now, fn -> @naive_date_time end)
    expect(NotificatorMock, :notify_success!, fn %Transaction{} -> nil end)
  end

  describe "call/2" do
    test "successfully" do
      mock()
      account = fixture!(:account, total: 10)
      transaction = fixture!(:transaction, value: 2, account_id: account.id)

      GiftProcessor.call(transaction, NotificatorMock)

      transaction = Repo.get!(Transaction, transaction.id)
      account = Repo.get!(Account, account.id)

      assert transaction.processed_at == @naive_date_time
      assert account.total == 12
    end
  end
end
