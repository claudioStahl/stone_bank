defmodule StoneBank.Accounts.TransactionFactories.GiftFactoryTest do
  use StoneBank.DataCase

  import StoneBank.Fixtures.Accounts

  alias StoneBank.Accounts.Transaction
  alias StoneBank.Accounts.TransactionFactories.GiftFactory

  describe "call/2" do
    test "with valid data creates a transaction" do
      account_id = fixture!(:account).id
      value = 1_000

      assert {:ok, %Transaction{} = transaction} = GiftFactory.call(account_id, value)
      assert transaction.account_id == account_id
      assert transaction.value == value
      assert transaction.action == "gift"
      assert transaction.kind == "inbound"
    end

    test "with invalid data returns error changeset" do
      account_id = nil
      value = nil

      assert {:error, %Ecto.Changeset{}} = GiftFactory.call(account_id, value)
    end
  end
end
