defmodule StoneBank.Accounts.AccountTest do
  use StoneBank.DataCase

  import StoneBank.Fixtures.Accounts

  alias StoneBank.Accounts.Account

  @valid_attrs %{name: "José Augusto", password: "654321", total: 1}

  describe "changeset/2" do
    test "with new account and valid data returns valid changeset" do
      assert %Ecto.Changeset{valid?: true, changes: changes} =
               Account.changeset(%Account{}, @valid_attrs)

      assert changes.name == @valid_attrs.name
      assert changes.total == @valid_attrs.total
      assert Argon2.verify_pass(@valid_attrs.password, changes.password_hash)
    end

    test "with persisted account and empty data returns valid changeset" do
      account = fixture(:account, insert: false)
      assert %Ecto.Changeset{valid?: true, changes: %{}} = Account.changeset(account, %{})
    end

    test "with persisted account and valid data returns valid changeset" do
      account = fixture(:account, insert: false)

      assert %Ecto.Changeset{valid?: true, changes: changes} =
               Account.changeset(account, @valid_attrs)

      assert changes.name == @valid_attrs.name
      assert changes.total == @valid_attrs.total
      assert Argon2.verify_pass(@valid_attrs.password, changes.password_hash)
    end

    test "with nill name returns error changeset" do
      attrs = %{@valid_attrs | name: nil}

      assert %Ecto.Changeset{valid?: false, errors: [name: {_, [validation: :required]}]} =
               Account.changeset(%Account{}, attrs)
    end

    test "with nill password returns error changeset" do
      attrs = %{@valid_attrs | password: nil}

      assert %Ecto.Changeset{valid?: false, errors: [password_hash: {_, [validation: :required]}]} =
               Account.changeset(%Account{}, attrs)
    end

    test "with short password returns error changeset" do
      attrs = %{@valid_attrs | password: "123"}

      assert %Ecto.Changeset{
               valid?: false,
               errors: [password: {_, [count: 6, validation: :length, kind: :min, type: :string]}]
             } = Account.changeset(%Account{}, attrs)
    end

    test "with total less than zero returns error changeset" do
      attrs = %{@valid_attrs | total: -1}

      assert %Ecto.Changeset{
               valid?: false,
               errors: [
                 total:
                   {_,
                    [
                      validation: :number,
                      kind: :greater_than_or_equal_to,
                      number: 0
                    ]}
               ]
             } = Account.changeset(%Account{}, attrs)
    end
  end

  describe "check_password/2" do
    test "returns valid response" do
      account = fixture(:account, insert: false)
      assert {:ok, account} = Account.check_password(account, "123456")
    end

    test "returns error response" do
      account = fixture(:account, insert: false)
      assert {:error, "invalid password"} = Account.check_password(account, "123")
    end
  end
end
