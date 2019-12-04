defmodule StoneBank.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias StoneBank.Repo
  alias StoneBank.Accounts.Account
  alias StoneBank.Accounts.AccountCallbacks
  alias StoneBank.Accounts.Transaction
  alias StoneBank.Accounts.TransactionQuery

  @transaction_processors Application.get_env(:stone_bank, :transaction_processors)
  @transaction_notificators Application.get_env(:stone_bank, :transaction_notificators)

  @callback create_account(String.t(), String.t()) ::
              {:ok, %Account{}} | {:error, %Ecto.Changeset{}}
  @callback create_account(String.t(), String.t(), AccountCallbacks.t()) ::
              {:ok, %Account{}} | {:error, %Ecto.Changeset{}}
  @callback get_account_by_number_and_password(integer, String.t()) ::
              {:ok, %Account{}} | {:error, :not_found}
  @callback load_next_transaction() :: %Transaction{}
  @callback process_transaction(%Transaction{}) :: {:ok, term}

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(name, password)
      {:ok, %Account{}}

      iex> create_account(bad_value, bad_value)
      {:error, %Ecto.Changeset{}}

  """
  def create_account(name, password, account_callbacks \\ AccountCallbacks) do
    changeset = Account.changeset(%Account{}, %{name: name, password: password})

    if changeset.valid? do
      Repo.transaction(fn ->
        account = Repo.insert!(changeset)
        account = Repo.get!(Account, account.id)
        account_callbacks.after_insert(account)
        account
      end)
    else
      {:error, changeset}
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

  @doc """
  Load next transaction to process it.
  This transaction has not yet been processed.

  """
  def load_next_transaction do
    Transaction
    |> TransactionQuery.where_uncompleted()
    |> first(:inserted_at)
    |> Repo.one()
  end

  @doc """
  Process a transaction.
  This may mean completing a transfer, withdrawal, or any other type of transaction.

  """
  def process_transaction(transaction) do
    Repo.transaction(fn ->
      transaction_processor = Map.fetch!(@transaction_processors, transaction.action)
      transaction_notificator = Map.fetch!(@transaction_notificators, transaction.action)
      transaction_processor.call(transaction, transaction_notificator)
    end)
  end
end
