defmodule StoneBank.Accounts.TransactionServerTest do
  use StoneBank.DataCase, async: true

  import Mox
  import StoneBank.GenServerTools
  import StoneBank.Fixtures.Accounts

  alias StoneBank.AccountsMock
  alias StoneBank.Accounts.TransactionServer

  setup :verify_on_exit!

  def start_server do
    parent_id = self()

    options = [
      count_listener: parent_id,
      before_init: fn -> allow(AccountsMock, parent_id, self()) end
    ]

    TransactionServer.start_link(options)
  end

  test "processes next transactions one time" do
    expect(AccountsMock, :load_next_transaction, 1, fn -> nil end)

    {:ok, server_pid} = start_server()

    assert_state(server_pid, 1)
  end

  test "processes next transactions two times" do
    transaction = fixture(:transaction)
    expect(AccountsMock, :load_next_transaction, fn -> transaction end)
    expect(AccountsMock, :load_next_transaction, fn -> nil end)
    expect(AccountsMock, :process_transaction, 1, fn _transaction -> nil end)

    {:ok, server_pid} = start_server()

    assert_state(server_pid, 2)
  end

  test "processes next transactions with notifications" do
    expect(AccountsMock, :load_next_transaction, 3, fn -> nil end)

    {:ok, server_pid} = start_server()
    send(server_pid, {:notification, self(), nil, "", %{}})
    send(server_pid, {:notification, self(), nil, "", %{}})

    assert_state(server_pid, 3)
  end
end
