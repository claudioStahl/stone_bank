defmodule StoneBank.Accounts.TransactionFactories.TransferenceFactoryTest do
  use StoneBank.DataCase

  import StoneBank.Fixtures.Accounts

  alias StoneBank.Accounts.TransactionFactories.TransferenceFactory

  describe "call/3" do
    test "with valid data creates two transactions" do
      source_account = fixture!(:account)
      destination_account = fixture!(:account, number: 3)
      value = 1_000

      assert {:ok, {outbound_transaction, inbound_transaction}} =
               TransferenceFactory.call(source_account.id, destination_account.number, value)

      assert outbound_transaction.account_id == source_account.id
      assert outbound_transaction.value == value
      assert outbound_transaction.action == "transference"
      assert outbound_transaction.kind == "outbound"

      assert inbound_transaction.account_id == destination_account.id
      assert inbound_transaction.value == value
      assert inbound_transaction.action == "transference"
      assert inbound_transaction.kind == "inbound"
    end

    test "with invalid destination account returns error" do
      source_account = fixture!(:account)
      destination_account_number = 9
      value = 1_000

      assert {:error, :destination_account_not_found} =
               TransferenceFactory.call(source_account.id, destination_account_number, value)
    end

    test "with invalid value returns error changeset" do
      source_account = fixture!(:account)
      destination_account = fixture!(:account, number: 3)
      value = -1_000

      assert {:error, %Ecto.Changeset{}} =
               TransferenceFactory.call(source_account.id, destination_account.number, value)
    end

    test "with unavailable limit returns error" do
      source_account = fixture!(:account, total: 1)
      destination_account = fixture!(:account, number: 3)
      value = 2

      assert {:error, :unavailable_limit} =
               TransferenceFactory.call(source_account.id, destination_account.number, value)
    end
  end
end
