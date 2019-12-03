defmodule StoneBank.Accounts.AccountCallbacksTest do
  use ExUnit.Case

  import Mox
  import StoneBank.Fixtures.Accounts

  alias StoneBank.Accounts.AccountCallbacks
  alias StoneBank.Accounts.TransactionFactories.GiftFactoryMock

  @gift_value Application.get_env(:stone_bank, :gift_value)

  setup :verify_on_exit!

  describe "after_insert/1" do
    test "returns valid response" do
      account_id = Ecto.UUID.generate()
      account = fixture(:account, id: account_id)
      transaction = fixture(:transaction)

      expect(
        GiftFactoryMock,
        :call,
        fn ^account_id, @gift_value ->
          {:ok, transaction}
        end
      )

      assert {:ok, ^transaction} = AccountCallbacks.after_insert(account)
    end
  end
end
