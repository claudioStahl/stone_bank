defmodule StoneBank.Accounts.AccountsTest do
  use StoneBank.DataCase

  import Mox
  import StoneBank.Fixtures.Accounts

  alias StoneBank.Accounts
  alias StoneBank.Accounts.Account
  alias StoneBank.Accounts.AccountCallbacksMock

  setup :verify_on_exit!

  describe "create_account/2" do
    test "with valid data creates a account" do
      expect(AccountCallbacksMock, :after_insert, fn %Account{} -> nil end)

      name = "some name"
      password = "123456"

      assert {:ok, %Account{} = account} = Accounts.create_account(name, password, AccountCallbacksMock)
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
end
