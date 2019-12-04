defmodule StoneBank.Accounts.AccountsTest do
  use StoneBank.DataCase

  import Mox
  import StoneBank.Fixtures.Accounts

  alias StoneBank.Accounts
  alias StoneBank.Accounts.{Account, Transaction, AccountCallbacksMock}

  alias StoneBank.Accounts.TransactionProcessors.{
    GiftProcessorMock,
    WithdrawalProcessorMock,
    TransferenceProcessorMock
  }

  alias StoneBank.Accounts.TransactionNotificators.{
    GiftNotificatorMock,
    WithdrawalNotificatorMock,
    TransferenceNotificatorMock
  }

  setup :verify_on_exit!

  describe "create_account/2" do
    test "with valid data creates a account" do
      expect(AccountCallbacksMock, :after_insert, fn %Account{} -> nil end)

      name = "some name"
      password = "123456"

      assert {:ok, %Account{} = account} =
               Accounts.create_account(name, password, AccountCallbacksMock)

      assert account.name == name
      assert Argon2.verify_pass(password, account.password_hash)
      assert account.total == 0
    end

    test "with invalid data returns error changeset" do
      name = ""
      password = ""

      assert {:error, %Ecto.Changeset{}} = Accounts.create_account(name, password)
    end
  end

  describe "get_account_by_number_and_password/2" do
    test "returns valid response" do
      account = fixture!(:account, number: 1)

      assert {:ok, found_account} =
               Accounts.get_account_by_number_and_password(account.number, account.password)

      assert found_account.id == account.id
    end

    test "with invalid number returns error response" do
      account = fixture!(:account, number: 1)

      assert {:error, :not_found} =
               Accounts.get_account_by_number_and_password(99, account.password)
    end

    test "with invalid password returns error response" do
      account = fixture!(:account, number: 1)

      assert {:error, :not_found} =
               Accounts.get_account_by_number_and_password(account.number, "123")
    end
  end

  describe "load_next_transaction" do
    test "returns a transaction" do
      transaction =
        fixture!(:transaction, processed_at: nil, inserted_at: ~N[2019-11-01 12:45:17])

      fixture!(:transaction,
        processed_at: ~N[2019-11-01 10:45:17],
        inserted_at: ~N[2019-11-01 10:45:17]
      )

      fixture!(:transaction, processed_at: nil, inserted_at: ~N[2019-11-02 12:45:17])

      assert %Transaction{} = transaction_result = Accounts.load_next_transaction()
      assert transaction_result.id == transaction.id
    end

    test "returns nil" do
      fixture!(:transaction, processed_at: ~N[2019-11-28 12:45:17])

      assert nil == Accounts.load_next_transaction()
    end
  end

  describe "process_transaction/1" do
    test "with gift transaction returns ok" do
      expect(GiftProcessorMock, :call, fn %Transaction{}, GiftNotificatorMock -> nil end)

      transaction = fixture!(:transaction, action: "gift")

      assert {:ok, nil} = Accounts.process_transaction(transaction)
    end

    test "with withdrawal transaction returns ok" do
      expect(WithdrawalProcessorMock, :call, fn %Transaction{}, WithdrawalNotificatorMock ->
        nil
      end)

      transaction = fixture!(:transaction, action: "withdrawal")

      assert {:ok, nil} = Accounts.process_transaction(transaction)
    end

    test "with transference transaction returns ok" do
      expect(TransferenceProcessorMock, :call, fn %Transaction{}, TransferenceNotificatorMock ->
        nil
      end)

      transaction = fixture!(:transaction, action: "transference")

      assert {:ok, nil} = Accounts.process_transaction(transaction)
    end
  end
end
