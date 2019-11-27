defmodule StoneBank.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias StoneBank.Repo

  alias StoneBank.Accounts.Account

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(name, password)
      {:ok, %Account{}}

      iex> create_account(bad_value, bad_value)
      {:error, %Ecto.Changeset{}}

  """
  def create_account(name, password) do
    with changeset <- Account.changeset(%Account{}, %{name: name, password: password}),
         {:ok, account} <- Repo.insert(changeset) do
      {:ok, Repo.get!(Account, account.id)}
    end
  end
end
