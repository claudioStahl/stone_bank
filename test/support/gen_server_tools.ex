defmodule StoneBank.GenServerTools do
  import ExUnit.Assertions

  def assert_state(server_pid, state, timeout \\ 1000) do
    parent_pid = self()

    Task.async(fn ->
      try_get_state(parent_pid, server_pid, state)
    end)

    assert_receive state, timeout
  end

  defp try_get_state(parent_pid, server_pid, state) do
    server_state = :sys.get_state(server_pid)
    send(parent_pid, server_state)

    if state != server_state do
      try_get_state(parent_pid, server_pid, state)
    end
  end
end
