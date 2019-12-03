defmodule StoneBank.Accounts.TransactionQueryTest do
  use StoneBank.DataCase

  import StoneBank.Fixtures.Accounts

  alias StoneBank.Repo
  alias StoneBank.Accounts.Transaction
  alias StoneBank.Accounts.TransactionQuery

  @processed_at ~N[2019-12-03 13:10:01]

  describe "where_uncompleted/1" do
    test "returns one item" do
      %Transaction{id: transaction_id} = fixture!(:transaction, processed_at: nil)
      fixture!(:transaction, processed_at: @processed_at)

      assert [%Transaction{id: ^transaction_id}] =
               TransactionQuery.where_uncompleted(Transaction)
               |> Repo.all()
    end

    test "returns zero item" do
      fixture!(:transaction, processed_at: @processed_at)
      fixture!(:transaction, processed_at: @processed_at)

      assert [] =
               TransactionQuery.where_uncompleted(Transaction)
               |> Repo.all()
    end
  end

  describe "where_completed/1" do
    test "returns one item" do
      %Transaction{id: transaction_id} =
        fixture!(:transaction, processed_at: @processed_at, error: nil)

      fixture!(:transaction, processed_at: @processed_at, error: "unavailable_limit")
      fixture!(:transaction, processed_at: nil, error: nil)

      assert [%Transaction{id: ^transaction_id}] =
               TransactionQuery.where_completed(Transaction)
               |> Repo.all()
    end

    test "returns zero item" do
      fixture!(:transaction, processed_at: @processed_at, error: "unavailable_limit")
      fixture!(:transaction, processed_at: nil, error: nil)

      assert [] =
               TransactionQuery.where_completed(Transaction)
               |> Repo.all()
    end
  end

  describe "where_unique_by_group/1" do
    test "returns one with group_id and all without group_id" do
      group_id = "4642f242-ffad-4f45-a03b-2950d7f91bf4"

      %Transaction{id: id_one} = fixture!(:transaction, group_id: group_id, kind: "outbound")
      fixture!(:transaction, group_id: group_id, kind: "inbound")
      fixture!(:transaction, group_id: group_id, kind: "inbound")
      %Transaction{id: id_two} = fixture!(:transaction, group_id: nil, kind: "outbound")
      %Transaction{id: id_three} = fixture!(:transaction, group_id: nil, kind: "inbound")

      result =
        TransactionQuery.where_unique_by_group(Transaction)
        |> Repo.all()

      Enum.each([id_one, id_two, id_three], fn id ->
        assert Enum.find(result, fn t -> t.id == id end)
      end)
    end
  end

  describe "where_processed_at_range/3" do
    test "returns all transactions between the range" do
      start = ~N[2019-12-03 13:10:01]
      finish = ~N[2019-12-06 13:10:01]

      %Transaction{id: id_one} = fixture!(:transaction, processed_at: ~N[2019-12-04 13:10:01])
      %Transaction{id: id_two} = fixture!(:transaction, processed_at: ~N[2019-12-04 14:10:01])
      %Transaction{id: id_three} = fixture!(:transaction, processed_at: ~N[2019-12-05 15:10:01])
      fixture!(:transaction, processed_at: ~N[2019-12-02 13:10:01])
      fixture!(:transaction, processed_at: ~N[2019-12-07 13:10:01])

      result =
        TransactionQuery.where_processed_at_range(Transaction, start, finish)
        |> Repo.all()

      Enum.each([id_one, id_two, id_three], fn id ->
        assert Enum.find(result, fn t -> t.id == id end)
      end)
    end
  end
end
