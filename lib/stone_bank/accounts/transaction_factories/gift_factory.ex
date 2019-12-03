defmodule StoneBank.Accounts.TransactionFactories.GiftFactory do
  alias StoneBank.Repo
  alias StoneBank.Accounts.Transaction

  @doc """
  Creates a gift transaction.

  ## Examples

      iex> call(account_id, 1000)
      {:ok, %Transaction{}}

      iex> call(bad_value, bad_value)
      {:error, %Ecto.Changeset{}}

  """
  def call(account_id, value) do
    attrs = %{
      account_id: account_id,
      value: value,
      action: "gift",
      kind: "inbound"
    }

    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end
end
