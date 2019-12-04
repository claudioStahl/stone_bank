defmodule StoneBank.Accounts.TransactionProcessors.HelperTest do
  use StoneBank.DataCase

  import Mox
  import StoneBank.Fixtures.Accounts

  alias StoneBank.TimeMock
  alias StoneBank.Accounts.Account
  alias StoneBank.Accounts.Transaction
  alias StoneBank.Accounts.TransactionProcessors.Helper

  setup :verify_on_exit!

  def mock do
    expect(TimeMock, :naive_date_time_utc_now, fn -> ~N[2019-12-03 13:10:01] end)
  end

  describe "mark_processed!/1" do
    test "returns success" do
      mock()
      transaction = fixture!(:transaction)
      assert %Transaction{} = Helper.mark_processed!(transaction)
    end

    test "returns error" do
      mock()

      assert_raise Ecto.InvalidChangesetError, fn ->
        Helper.mark_processed!(%Transaction{})
      end
    end
  end

  describe "mark_processed_with_error!/1" do
    test "returns success" do
      mock()
      error = "unavailable_limit"
      transaction = fixture!(:transaction)
      assert %Transaction{error: ^error} = Helper.mark_processed_with_error!(transaction, error)
    end

    test "returns error" do
      mock()
      error = "unavailable_limit"

      assert_raise Ecto.InvalidChangesetError, fn ->
        Helper.mark_processed_with_error!(%Transaction{}, error)
      end
    end
  end

  describe "apply_inbound!/1" do
    test "returns success" do
      account = fixture!(:account, total: 5)
      assert %Account{total: 6} = Helper.apply_inbound!(account, 1)
    end

    test "returns error" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        Helper.apply_inbound!(%Account{}, 1)
      end
    end
  end

  describe "apply_outbound!/1" do
    test "returns success" do
      account = fixture!(:account, total: 5)
      assert %Account{total: 4} = Helper.apply_outbound!(account, 1)
    end

    test "returns error" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        Helper.apply_outbound!(%Account{}, 1)
      end
    end
  end
end
