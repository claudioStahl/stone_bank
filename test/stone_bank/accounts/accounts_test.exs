defmodule StoneBank.Accounts.AccountsTest do
  use StoneBank.DataCase

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
end
