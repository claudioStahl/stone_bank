defmodule StoneBank.Fixtures.Accounts do
  alias StoneBank.Repo
  alias StoneBank.Accounts.Account

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
end
