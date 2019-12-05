defmodule StoneBank.Accounts.TransactionServer do
  @moduledoc """
  The transaction server processes transactions one at a time,
  avoiding problems with competition.
  """

  use GenServer

  require Logger

  alias Postgrex.Notifications

  @channel "new_transaction"
  @accounts Application.get_env(:stone_bank, :accounts_module)

  def start_link(options) do
    Logger.info("Starting the #{__MODULE__}...")

    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  # GenServer callbacks

  def init(options) do
    call_before_init(options)

    send_poll()

    {:ok, pid} = Notifications.start_link(StoneBank.Repo.config())
    {:ok, _ref} = Notifications.listen(pid, @channel)
    {:ok, 0}
  end

  def handle_info({:notification, _pid, _ref, _channel, _payload}, state) do
    process_next_transaction()
    {:noreply, state + 1}
  end

  def handle_info(:poll, state) do
    process_next_transaction()
    {:noreply, state + 1}
  end

  defp process_next_transaction do
    Logger.info("Process next transaction...")

    transaction = @accounts.load_next_transaction()

    if transaction do
      @accounts.process_transaction(transaction)

      if not has_comum_messages?(), do: send_poll()
    end
  end

  defp send_poll do
    send(self(), :poll)
  end

  defp call_before_init(options) do
    if before_init = options[:before_init] do
      before_init.()
    end
  end

  defp has_comum_messages? do
    {:messages, messages} = Process.info(self(), :messages)
    messages |> Enum.any?(fn message -> elem(message, 0) != :system end)
  end
end
