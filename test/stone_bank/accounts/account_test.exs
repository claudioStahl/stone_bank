defmodule StoneBank.Accounts.AccountTest do
  use StoneBank.DataCase, async: true

  import StoneBank.Fixtures.Accounts

  alias StoneBank.Accounts.Account

  @valid_attrs %{name: "José Augusto", password: "654321", total: 500}

  describe "changeset/2" do
    test "with new account and valid data returns valid changeset" do
      assert %Ecto.Changeset{valid?: true, changes: changes} =
               Account.changeset(%Account{}, @valid_attrs)

      assert changes.name == @valid_attrs.name
      assert changes.total == @valid_attrs.total
      assert Argon2.verify_pass(@valid_attrs.password, changes.password_hash)
    end

    test "with persisted account and empty data returns valid changeset" do
      account = fixture(:account)
      assert %Ecto.Changeset{valid?: true, changes: %{}} = Account.changeset(account, %{})
    end

    test "with persisted account and valid data returns valid changeset" do
      account = fixture(:account, total: 1000)

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
      account = fixture(:account)
      assert {:ok, account} = Account.check_password(account, "123456")
    end

    test "returns error response" do
      account = fixture(:account)
      assert {:error, "invalid password"} = Account.check_password(account, "123")
    end
  end

  describe "check_available_limit/2" do
    test "returns valid response" do
      account = fixture(:account, total: 3)
      assert {:ok, account} = Account.check_available_limit(account, 2)
    end

    test "returns error response" do
      account = fixture(:account, total: 1)
      assert {:error, :unavailable_limit} = Account.check_available_limit(account, 2)
    end
  end

  describe "apply_inbound/2" do
    test "with changeset" do
      changeset = Account.changeset(%Account{}, @valid_attrs)
      assert %Ecto.Changeset{valid?: true, changes: changes} = Account.apply_inbound(changeset, 1)
      assert changes.total == 501
    end

    test "with account" do
      account = fixture(:account, total: 500)
      assert %Ecto.Changeset{valid?: true, changes: changes} = Account.apply_inbound(account, 1)
      assert changes.total == 501
    end
  end

  describe "apply_outbound/2" do
    test "with changeset" do
      changeset = Account.changeset(%Account{}, @valid_attrs)

      assert %Ecto.Changeset{valid?: true, changes: changes} =
               Account.apply_outbound(changeset, 1)

      assert changes.total == 499
    end

    test "with account" do
      account = fixture(:account, total: 500)
      assert %Ecto.Changeset{valid?: true, changes: changes} = Account.apply_outbound(account, 1)
      assert changes.total == 499
    end
  end
end
