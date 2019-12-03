defmodule StoneBank.Accounts.AccountsTest do
  use StoneBank.DataCase

  import StoneBank.Fixtures.Accounts

  alias StoneBank.Accounts
  alias StoneBank.Accounts.Account

  describe "create_account/2" do
    test "with valid data creates a account" do
      name = "some name"
      password = "123456"

      assert {:ok, %Account{} = account} = Accounts.create_account(name, password)
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
      account = fixture!(:account)

      assert {:ok, found_account} =
               Accounts.get_account_by_number_and_password(account.number, account.password)

      assert found_account.id == account.id
    end

    test "with invalid number returns error response" do
      account = fixture!(:account)

      assert {:error, :not_found} =
               Accounts.get_account_by_number_and_password(99, account.password)
    end

    test "with invalid password returns error response" do
      account = fixture!(:account)

      assert {:error, :not_found} =
               Accounts.get_account_by_number_and_password(account.number, "123")
    end
  end
end
