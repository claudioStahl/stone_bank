defmodule StoneBank.Accounts.TransactionNotificators.DefaultNotificatorTest do
  use ExUnit.Case

  import StoneBank.Fixtures.Accounts
  import ExUnit.CaptureLog

  alias StoneBank.Accounts.TransactionNotificators.DefaultNotificator

  describe "notify_success!/1" do
    test "log success" do
      transaction = fixture(:transaction)

      assert capture_log(fn ->
               DefaultNotificator.notify_success!(transaction)
             end) =~ "Notify success to transaction ##{transaction.id}"
    end
  end

  describe "notify_fail!/1" do
    test "log fail" do
      transaction = fixture(:transaction)

      assert capture_log(fn ->
               DefaultNotificator.notify_fail!(transaction)
             end) =~ "Notify fail to transaction ##{transaction.id}"
    end
  end
end
