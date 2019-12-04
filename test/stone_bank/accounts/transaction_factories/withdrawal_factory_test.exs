defmodule StoneBank.Accounts.TransactionFactories.WithdrawalFactoryTest do
  use StoneBank.DataCase, async: true

  import StoneBank.Fixtures.Accounts

  alias StoneBank.Accounts.TransactionFactories.WithdrawalFactory

  describe "call/2" do
    test "with valid data creates a transaction" do
      account = fixture!(:account)
      value = 1_000

      assert {:ok, transaction} = WithdrawalFactory.call(account.id, value)

      assert transaction.account_id == account.id
      assert transaction.value == value
      assert transaction.action == "withdrawal"
      assert transaction.kind == "outbound"
    end

    test "with invalid value returns error changeset" do
      account = fixture!(:account)
      value = -1_000

      assert {:error, %Ecto.Changeset{}} = WithdrawalFactory.call(account.id, value)
    end

    test "with unavailable limit returns error" do
      account = fixture!(:account, total: 1)
      value = 2

      assert {:error, :unavailable_limit} = WithdrawalFactory.call(account.id, value)
    end
  end
end
