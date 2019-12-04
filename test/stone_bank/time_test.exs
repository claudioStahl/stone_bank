defmodule StoneBank.TimeTest do
  use ExUnit.Case, async: true

  describe "utc_now" do
    test "returns valid response" do
      assert {{year, month, day}, {hour, minute, second}, {microseconds, precision}} =
               StoneBank.Time.utc_now()
    end
  end

  describe "naive_date_time_utc_now/1" do
    test "with microseconds" do
      assert %NaiveDateTime{} = naive_date_time = StoneBank.Time.naive_date_time_utc_now(true)
      assert {microseconds, 6} = naive_date_time.microsecond
    end

    test "without microseconds" do
      assert %NaiveDateTime{} = naive_date_time = StoneBank.Time.naive_date_time_utc_now()
      assert {0, 0} = naive_date_time.microsecond
    end
  end
end
