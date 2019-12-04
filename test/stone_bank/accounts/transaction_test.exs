defmodule StoneBank.Accounts.TransactionTest do
  use StoneBank.DataCase, async: true

  import Mox
  import StoneBank.Fixtures.Accounts

  alias StoneBank.TimeMock
  alias StoneBank.Accounts.Transaction

  @valid_attrs %{
    error: "unavailable_limit",
    group_id: "fef38acd-79c3-4a5a-9e83-6abb548a995a",
    action: "transference",
    kind: "outbound",
    processed_at: ~N[2019-10-25 12:45:17],
    value: 20_000,
    account_id: "3c87e7f7-90ff-417b-ba33-eb895ac05080"
  }

  setup :verify_on_exit!

  describe "changeset/2" do
    test "with new transaction and valid data returns valid changeset" do
      assert %Ecto.Changeset{valid?: true, changes: changes} =
               Transaction.changeset(%Transaction{}, @valid_attrs)

      assert changes.error == @valid_attrs.error
      assert changes.group_id == @valid_attrs.group_id
      assert changes.action == @valid_attrs.action
      assert changes.kind == @valid_attrs.kind
      assert changes.processed_at == @valid_attrs.processed_at
      assert changes.value == @valid_attrs.value
      assert changes.account_id == @valid_attrs.account_id
    end

    test "with persisted transaction and empty data returns valid changeset" do
      transaction = fixture(:transaction)
      assert %Ecto.Changeset{valid?: true, changes: %{}} = Transaction.changeset(transaction, %{})
    end

    test "with persisted transaction and valid data returns valid changeset" do
      transaction = fixture(:transaction)

      assert %Ecto.Changeset{valid?: true, changes: changes} =
               Transaction.changeset(transaction, @valid_attrs)

      assert changes.error == @valid_attrs.error
      assert changes.group_id == @valid_attrs.group_id
      assert changes.action == @valid_attrs.action
      assert changes.kind == @valid_attrs.kind
      assert changes.processed_at == @valid_attrs.processed_at
      assert changes.value == @valid_attrs.value
      assert changes.account_id == @valid_attrs.account_id
    end

    test "with nill action returns error changeset" do
      attrs = %{@valid_attrs | action: nil}

      assert %Ecto.Changeset{valid?: false, errors: [action: {_, [validation: :required]}]} =
               Transaction.changeset(%Transaction{}, attrs)
    end

    test "with nill kind returns error changeset" do
      attrs = %{@valid_attrs | kind: nil}

      assert %Ecto.Changeset{valid?: false, errors: [kind: {_, [validation: :required]}]} =
               Transaction.changeset(%Transaction{}, attrs)
    end

    test "with nill value returns error changeset" do
      attrs = %{@valid_attrs | value: nil}

      assert %Ecto.Changeset{valid?: false, errors: [value: {_, [validation: :required]}]} =
               Transaction.changeset(%Transaction{}, attrs)
    end

    test "with nill account id returns error changeset" do
      attrs = %{@valid_attrs | account_id: nil}

      assert %Ecto.Changeset{valid?: false, errors: [account_id: {_, [validation: :required]}]} =
               Transaction.changeset(%Transaction{}, attrs)
    end

    test "with invalid error returns error changeset" do
      attrs = %{@valid_attrs | error: "a"}

      assert %Ecto.Changeset{
               valid?: false,
               errors: [error: {_, [validation: :inclusion, enum: _]}]
             } = Transaction.changeset(%Transaction{}, attrs)
    end

    test "with invalid action returns error changeset" do
      attrs = %{@valid_attrs | action: "a"}

      assert %Ecto.Changeset{
               valid?: false,
               errors: [action: {_, [validation: :inclusion, enum: _]}]
             } = Transaction.changeset(%Transaction{}, attrs)
    end

    test "with invalid kind returns error changeset" do
      attrs = %{@valid_attrs | kind: "a"}

      assert %Ecto.Changeset{
               valid?: false,
               errors: [kind: {_, [validation: :inclusion, enum: _]}]
             } = Transaction.changeset(%Transaction{}, attrs)
    end

    test "with value less than zero returns error changeset" do
      attrs = %{@valid_attrs | value: -1}

      assert %Ecto.Changeset{
               valid?: false,
               errors: [
                 value:
                   {_,
                    [
                      validation: :number,
                      kind: :greater_than_or_equal_to,
                      number: 0
                    ]}
               ]
             } = Transaction.changeset(%Transaction{}, attrs)
    end
  end

  describe "mark_processed/1" do
    test "with changeset" do
      expect(TimeMock, :naive_date_time_utc_now, fn -> ~N[2019-12-03 13:10:01] end)

      changeset = Transaction.changeset(%Transaction{}, @valid_attrs)

      assert %Ecto.Changeset{valid?: true, changes: changes} =
               Transaction.mark_processed(changeset)

      assert changes.processed_at == ~N[2019-12-03 13:10:01]
    end

    test "with transaction" do
      expect(TimeMock, :naive_date_time_utc_now, fn -> ~N[2019-12-03 13:10:01] end)

      transaction = fixture(:transaction)

      assert %Ecto.Changeset{valid?: true, changes: changes} =
               Transaction.mark_processed(transaction)

      assert changes.processed_at == ~N[2019-12-03 13:10:01]
    end
  end

  describe "add_error/2" do
    test "with changeset" do
      changeset = Transaction.changeset(%Transaction{}, @valid_attrs)

      assert %Ecto.Changeset{valid?: true, changes: changes} =
               Transaction.add_error(changeset, "unavailable_limit")

      assert changes.error == "unavailable_limit"
    end

    test "with transaction" do
      transaction = fixture(:transaction)

      assert %Ecto.Changeset{valid?: true, changes: changes} =
               Transaction.add_error(transaction, "unavailable_limit")

      assert changes.error == "unavailable_limit"
    end
  end
end
