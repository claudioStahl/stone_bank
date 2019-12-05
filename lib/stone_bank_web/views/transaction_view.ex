defmodule StoneBankWeb.TransactionView do
  use StoneBankWeb, :view
  alias StoneBankWeb.TransactionView

  def render("index.json", %{transactions: transactions}) do
    %{data: render_many(transactions, TransactionView, "transaction.json")}
  end

  def render("show.json", %{transaction: transaction}) do
    %{data: render_one(transaction, TransactionView, "transaction.json")}
  end

  def render("transaction.json", %{transaction: transaction}) do
    %{
      id: transaction.id,
      action: transaction.action,
      kind: transaction.kind,
      value: transaction.value,
      processed_at: transaction.processed_at,
      error: transaction.error,
      inserted_at: transaction.inserted_at
    }
  end
end
