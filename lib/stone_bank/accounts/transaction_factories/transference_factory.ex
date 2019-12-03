defmodule StoneBank.Accounts.TransactionFactories.TransferenceFactory do
  import StoneBank.ChangesetHelper

  alias StoneBank.Repo
  alias StoneBank.Accounts.Account
  alias StoneBank.Accounts.Transaction

  @callback call(String.t(), integer, integer) ::
              {:ok, %Transaction{}}
              | {:error, %Ecto.Changeset{}}
              | {:error, :destination_account_not_found}
              | {:error, :unavailable_limit}

  @doc """
  Creates a transference transaction with destination account.

  ## Examples

      iex> call(source_account_id, destination_account, 1000)
      {:ok, {%Transaction{}, %Transaction{}}}

      iex> call(source_account_id, destination_account, bad_value)
      {:error, %Ecto.Changeset{}}

      iex> call(source_account_id, destination_account, bad_value)
      {:error, :unavailable_limit}

  """
  def call(source_account_id, %Account{} = destination_account, value) do
    group_id = Ecto.UUID.generate()
    source_account = Repo.get!(Account, source_account_id)
    outbound_changeset = build_outbound_changeset(source_account_id, value, group_id)
    inbound_changeset = build_inbound_changeset(destination_account.id, value, group_id)

    with {:ok, outbound_changeset} <- check_changeset(outbound_changeset),
         {:ok, _account} <- Account.check_available_limit(source_account, value) do
      Repo.transaction(fn ->
        outbound_transaction = Repo.insert!(outbound_changeset)
        inbound_transaction = Repo.insert!(inbound_changeset)
        {outbound_transaction, inbound_transaction}
      end)
    end
  end

  @doc """
  Creates a transference transaction with destination account number.

  ## Examples

      iex> call(source_account_id, destination_account, 1000)
      {:ok, {%Transaction{}, %Transaction{}}}

      iex> call(source_account_id, destination_account, bad_value)
      {:error, %Ecto.Changeset{}}

      iex> call(source_account_id, destination_account, bad_value)
      {:error, :unavailable_limit}

      iex> call(source_account_id, invalid_account_number, 1000)
      {:error, :destination_account_not_found}

  """
  def call(source_account_id, destination_account_number, value) do
    destination_account = Repo.get_by(Account, number: destination_account_number)

    if destination_account do
      call(source_account_id, destination_account, value)
    else
      {:error, :destination_account_not_found}
    end
  end

  defp build_outbound_changeset(account_id, value, group_id) do
    build_changeset(account_id, value, group_id, "outbound")
  end

  defp build_inbound_changeset(account_id, value, group_id) do
    build_changeset(account_id, value, group_id, "inbound")
  end

  defp build_changeset(account_id, value, group_id, kind) do
    Transaction.changeset(%Transaction{}, %{
      account_id: account_id,
      value: value,
      group_id: group_id,
      kind: kind,
      action: "transference"
    })
  end
end
