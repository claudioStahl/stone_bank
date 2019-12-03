defmodule StoneBank.Fixtures.Accounts do
  alias StoneBank.Repo
  alias StoneBank.Accounts.Account
  alias StoneBank.Accounts.Transaction

  @password "123456"

  def fixture(:account, params) do
    %Account{
      name: Keyword.get(params, :name, "Brian Cardarella"),
      number: Keyword.get(params, :number, nil),
      password: Keyword.get(params, :password, @password),
      password_hash: Keyword.get(params, :password_hash, Argon2.hash_pwd_salt(@password)),
      total: Keyword.get(params, :total, 1_000)
    }
  end

  def fixture(:account), do: fixture(:account, [])

  def fixture(:transaction, params) do
    %Transaction{
      error: Keyword.get(params, :error, nil),
      group_id: Keyword.get(params, :group_id, "4642f242-ffad-4f45-a03b-2950d7f91bf4"),
      action: Keyword.get(params, :action, "withdrawal"),
      kind: Keyword.get(params, :kind, "inbound"),
      processed_at: Keyword.get(params, :processed_at, ~N[2019-11-28 12:45:17]),
      value: Keyword.get(params, :value, 10_000),
      account_id: Keyword.get(params, :account_id, "4ed4970d-3d87-45f6-8269-fc764c35d8ac")
    }
  end

  def fixture(:transaction), do: fixture(:transaction, [])

  def fixture!(:account, params) do
    fixture(:account, params)
    |> Repo.insert!()
  end

  def fixture!(:account), do: fixture!(:account, [])

  def fixture!(:transaction, params) do
    params = Keyword.put_new(params, :account_id, fixture!(:account).id)

    fixture(:transaction, params)
    |> Repo.insert!()
  end

  def fixture!(:transaction), do: fixture!(:transaction, [])
end
