defmodule StoneBank.Accounts.TransactionQuery do
  import Ecto.Query, warn: false

  def where_uncompleted(query) do
    query
    |> where([t], is_nil(t.processed_at))
  end

  def where_completed(query) do
    query
    |> where([t], not is_nil(t.processed_at) and is_nil(t.error))
  end

  def where_unique_by_group(query) do
    query
    |> where([t], is_nil(t.group_id) or t.kind == "outbound")
  end

  def where_processed_at_range(query, %NaiveDateTime{} = start, %NaiveDateTime{} = finish) do
    query
    |> where([t], fragment("? BETWEEN ? AND ?", t.processed_at, ^start, ^finish))
  end
end
