defmodule StoneBank.Time do
  @callback utc_now() :: {:calendar.date(), :calendar.time(), Calendar.microsecond()}
  @callback naive_date_time_utc_now() :: NaiveDateTime.t()
  @callback naive_date_time_utc_now(boolean) :: NaiveDateTime.t()

  def utc_now do
    {:ok, date, time, microsecond} = Calendar.ISO.from_unix(:os.system_time(), :native)
    {date, time, microsecond}
  end

  def naive_date_time_utc_now(with_micro \\ false) do
    {date, time, microsecond} = utc_now()

    if with_micro do
      NaiveDateTime.from_erl!({date, time}, microsecond)
    else
      NaiveDateTime.from_erl!({date, time})
    end
  end
end
