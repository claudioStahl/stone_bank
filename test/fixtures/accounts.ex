defmodule StoneBank.Fixtures.Accounts do
  alias StoneBank.Repo
  alias StoneBank.Accounts.Account
  alias StoneBank.Accounts.Transaction

  @password "123456"

  def fixture(:account, insert: false) do
    %Account{
      name: "Brian Cardarella",
      number: 1,
      password: @password,
      password_hash: Argon2.hash_pwd_salt(@password),
      total: 1_000
    }
  end

  def fixture(:account, insert: true) do
    Repo.insert!(%Account{
      name: "Brian Cardarella",
      number: 1,
      password: @password,
      password_hash: Argon2.hash_pwd_salt(@password),
      total: 1_000
    })
  end

  def fixture(:transaction, insert: false) do
    %Transaction{
      error: nil,
      group_id: "4642f242-ffad-4f45-a03b-2950d7f91bf4",
      action: "withdrawal",
      kind: "inbound",
      processed_at: ~N[2019-11-28 12:45:17],
      value: 10_000,
      account_id: "4ed4970d-3d87-45f6-8269-fc764c35d8ac"
    }
  end
end
