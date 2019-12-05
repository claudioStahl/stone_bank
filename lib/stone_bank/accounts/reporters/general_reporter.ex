defmodule StoneBank.Accounts.Reporters.GeneralReporter do
  import Ecto.Query, warn: false

  alias StoneBank.Repo
  alias StoneBank.Accounts.Transaction
  alias StoneBank.Accounts.TransactionQuery

  @time_module Application.get_env(:stone_bank, :time_module)
  @intervals ["year", "month", "day"]
  @default_start ~N[1970-01-01 00:00:00]

  @callback call(String.t(), String.t()) ::
              {:ok, Map.t()} | {:error, :invalid_format}

  def call(start, finish) do
    with {:ok, start} <- parse_date(start),
         {:ok, finish} <- parse_date(finish) do
      {:ok, generate_report(start, finish)}
    end
  end

  defp parse_date(nil), do: {:ok, nil}
  defp parse_date(""), do: {:ok, nil}

  defp parse_date(str_date) do
    NaiveDateTime.from_iso8601(str_date)
  end

  defp generate_report(start, finish) do
    %{
      days: query_by_interval(start, finish, "day"),
      months: query_by_interval(start, finish, "month"),
      years: query_by_interval(start, finish, "year"),
      total: query_total(start, finish)
    }
  end

  defp query_by_interval(start, finish, interval) when interval in @intervals do
    Transaction
    |> select([t], [
      fragment("DATE(date_trunc(?, ?)) as date", ^interval, t.processed_at),
      t.action,
      fragment("cast(sum(?) as integer)", t.value)
    ])
    |> group_by([t], [t.action, fragment("date")])
    |> TransactionQuery.where_completed()
    |> TransactionQuery.where_unique_by_group()
    |> where_processed_at_range(start, finish)
    |> order_by(fragment("date"))
    |> order_by([t], t.action)
    |> Repo.all()
    |> build_objects(["date", "kind", "value"])
  end

  defp query_total(start, finish) do
    Transaction
    |> select([t], [t.action, fragment("cast(sum(?) as integer)", t.value)])
    |> group_by([t], [t.action])
    |> TransactionQuery.where_completed()
    |> TransactionQuery.where_unique_by_group()
    |> where_processed_at_range(start, finish)
    |> order_by([t], t.action)
    |> Repo.all()
    |> build_objects(["kind", "value"])
  end

  defp where_processed_at_range(query, start, finish) do
    start = start || @default_start
    finish = finish || @time_module.naive_date_time_utc_now()

    TransactionQuery.where_processed_at_range(query, start, finish)
  end

  defp build_objects(rows, titles) do
    rows
    |> Enum.map(fn row -> build_object(row, titles) end)
  end

  defp build_object(row, titles) do
    row
    |> Enum.zip(titles)
    |> Enum.reduce(%{}, fn {value, title}, acc -> Map.put(acc, title, value) end)
  end
end
