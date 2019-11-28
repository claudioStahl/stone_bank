defmodule StoneBank.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias StoneBank.Repo

  alias StoneBank.Accounts.Account

  @callback create_account(String.t(), String.t()) ::
              {:ok, %Account{}} | {:error, %Ecto.Changeset{}}
  @callback get_account_by_number_and_password(integer, String.t()) ::
              {:ok, %Account{}} | {:error, :not_found}

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

  @doc """
  Gets a single account by number and password.

  ## Examples

      iex> get_account_by_number_and_password(number, password)
      {:ok, %Account{}}

      iex> get_account_by_number_and_password(number, password)
      {:error, :not_found}

  """
  def get_account_by_number_and_password(number, password) do
    with account <- Repo.get_by(Account, number: number),
         {:ok, account} <- Account.check_password(account, password) do
      {:ok, account}
    else
      _ -> {:error, :not_found}
    end
  end
end
