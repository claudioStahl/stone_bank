defmodule StoneBank.Accounts.Reporters.GeneralReporterTest do
  use StoneBank.DataCase, async: true

  import Mox
  import StoneBank.Fixtures.Accounts

  alias Ecto.UUID
  alias StoneBank.TimeMock
  alias StoneBank.Accounts.Reporters.GeneralReporter

  setup :verify_on_exit!

  def mock do
    expect(TimeMock, :naive_date_time_utc_now, 4, fn -> ~N[2019-12-20 13:10:01] end)
  end

  def fixtures! do
    fixture!(:transaction,
      value: 800,
      action: "gift",
      kind: "outbound",
      processed_at: ~N[2017-12-09 13:10:01]
    )

    fixture!(:transaction,
      value: 800,
      action: "gift",
      kind: "outbound",
      processed_at: ~N[2018-12-09 13:10:01]
    )

    group_id = UUID.generate()

    fixture!(:transaction,
      value: 400,
      action: "transference",
      group_id: group_id,
      kind: "outbound",
      processed_at: ~N[2019-12-08 13:10:01]
    )

    fixture!(:transaction,
      value: 400,
      action: "transference",
      group_id: group_id,
      kind: "inbound",
      processed_at: ~N[2019-12-08 13:10:01]
    )

    fixture!(:transaction,
      value: 600,
      action: "gift",
      kind: "outbound",
      processed_at: ~N[2019-12-08 13:10:01]
    )

    fixture!(:transaction,
      value: 700,
      action: "gift",
      kind: "outbound",
      processed_at: ~N[2019-12-09 13:10:01]
    )

    fixture!(:transaction,
      value: 500,
      action: "withdrawal",
      kind: "outbound",
      processed_at: ~N[2019-12-11 13:10:01]
    )
  end

  describe "call/2" do
    test "with valid start and finish params" do
      start = "2017-12-01 13:10:01"
      finish = "2019-12-10 13:10:01"
      fixtures!()
      assert {:ok, result} = GeneralReporter.call(start, finish)

      assert %{
               days: [
                 %{"date" => ~D[2017-12-09], "kind" => "gift", "value" => 800},
                 %{"date" => ~D[2018-12-09], "kind" => "gift", "value" => 800},
                 %{"date" => ~D[2019-12-08], "kind" => "gift", "value" => 600},
                 %{"date" => ~D[2019-12-08], "kind" => "transference", "value" => 400},
                 %{"date" => ~D[2019-12-09], "kind" => "gift", "value" => 700}
               ],
               months: [
                 %{"date" => ~D[2017-12-01], "kind" => "gift", "value" => 800},
                 %{"date" => ~D[2018-12-01], "kind" => "gift", "value" => 800},
                 %{"date" => ~D[2019-12-01], "kind" => "gift", "value" => 1300},
                 %{"date" => ~D[2019-12-01], "kind" => "transference", "value" => 400}
               ],
               total: [
                 %{"kind" => "gift", "value" => 2900},
                 %{"kind" => "transference", "value" => 400}
               ],
               years: [
                 %{"date" => ~D[2017-01-01], "kind" => "gift", "value" => 800},
                 %{"date" => ~D[2018-01-01], "kind" => "gift", "value" => 800},
                 %{"date" => ~D[2019-01-01], "kind" => "gift", "value" => 1300},
                 %{"date" => ~D[2019-01-01], "kind" => "transference", "value" => 400}
               ]
             } == result
    end

    test "with valid start and nil finish params" do
      mock()
      start = "2017-12-01 13:10:01"
      finish = nil
      fixtures!()
      assert {:ok, result} = GeneralReporter.call(start, finish)

      assert %{
               days: [
                 %{"date" => ~D[2017-12-09], "kind" => "gift", "value" => 800},
                 %{"date" => ~D[2018-12-09], "kind" => "gift", "value" => 800},
                 %{"date" => ~D[2019-12-08], "kind" => "gift", "value" => 600},
                 %{"date" => ~D[2019-12-08], "kind" => "transference", "value" => 400},
                 %{"date" => ~D[2019-12-09], "kind" => "gift", "value" => 700},
                 %{"date" => ~D[2019-12-11], "kind" => "withdrawal", "value" => 500}
               ],
               months: [
                 %{"date" => ~D[2017-12-01], "kind" => "gift", "value" => 800},
                 %{"date" => ~D[2018-12-01], "kind" => "gift", "value" => 800},
                 %{"date" => ~D[2019-12-01], "kind" => "gift", "value" => 1300},
                 %{"date" => ~D[2019-12-01], "kind" => "transference", "value" => 400},
                 %{"date" => ~D[2019-12-01], "kind" => "withdrawal", "value" => 500}
               ],
               total: [
                 %{"kind" => "gift", "value" => 2900},
                 %{"kind" => "transference", "value" => 400},
                 %{"kind" => "withdrawal", "value" => 500}
               ],
               years: [
                 %{"date" => ~D[2017-01-01], "kind" => "gift", "value" => 800},
                 %{"date" => ~D[2018-01-01], "kind" => "gift", "value" => 800},
                 %{"date" => ~D[2019-01-01], "kind" => "gift", "value" => 1300},
                 %{"date" => ~D[2019-01-01], "kind" => "transference", "value" => 400},
                 %{"date" => ~D[2019-01-01], "kind" => "withdrawal", "value" => 500}
               ]
             } == result
    end

    test "with valid finish and nil start params" do
      start = nil
      finish = "2018-12-10 13:10:01"
      fixtures!()
      assert {:ok, result} = GeneralReporter.call(start, finish)

      assert %{
               days: [
                 %{"date" => ~D[2017-12-09], "kind" => "gift", "value" => 800},
                 %{"date" => ~D[2018-12-09], "kind" => "gift", "value" => 800}
               ],
               months: [
                 %{"date" => ~D[2017-12-01], "kind" => "gift", "value" => 800},
                 %{"date" => ~D[2018-12-01], "kind" => "gift", "value" => 800}
               ],
               total: [%{"kind" => "gift", "value" => 1600}],
               years: [
                 %{"date" => ~D[2017-01-01], "kind" => "gift", "value" => 800},
                 %{"date" => ~D[2018-01-01], "kind" => "gift", "value" => 800}
               ]
             } == result
    end

    test "with empty finish and start params" do
      mock()
      start = ""
      finish = ""
      fixtures!()
      assert {:ok, result} = GeneralReporter.call(start, finish)

      assert %{
               days: [
                 %{"date" => ~D[2017-12-09], "kind" => "gift", "value" => 800},
                 %{"date" => ~D[2018-12-09], "kind" => "gift", "value" => 800},
                 %{"date" => ~D[2019-12-08], "kind" => "gift", "value" => 600},
                 %{"date" => ~D[2019-12-08], "kind" => "transference", "value" => 400},
                 %{"date" => ~D[2019-12-09], "kind" => "gift", "value" => 700},
                 %{"date" => ~D[2019-12-11], "kind" => "withdrawal", "value" => 500}
               ],
               months: [
                 %{"date" => ~D[2017-12-01], "kind" => "gift", "value" => 800},
                 %{"date" => ~D[2018-12-01], "kind" => "gift", "value" => 800},
                 %{"date" => ~D[2019-12-01], "kind" => "gift", "value" => 1300},
                 %{"date" => ~D[2019-12-01], "kind" => "transference", "value" => 400},
                 %{"date" => ~D[2019-12-01], "kind" => "withdrawal", "value" => 500}
               ],
               total: [
                 %{"kind" => "gift", "value" => 2900},
                 %{"kind" => "transference", "value" => 400},
                 %{"kind" => "withdrawal", "value" => 500}
               ],
               years: [
                 %{"date" => ~D[2017-01-01], "kind" => "gift", "value" => 800},
                 %{"date" => ~D[2018-01-01], "kind" => "gift", "value" => 800},
                 %{"date" => ~D[2019-01-01], "kind" => "gift", "value" => 1300},
                 %{"date" => ~D[2019-01-01], "kind" => "transference", "value" => 400},
                 %{"date" => ~D[2019-01-01], "kind" => "withdrawal", "value" => 500}
               ]
             } == result
    end

    test "with valid finish and invalid start params" do
      start = "2017-12-01 a"
      finish = "2019-12-10 13:10:01"

      assert {:error, :invalid_format} = GeneralReporter.call(start, finish)
    end

    test "with valid start and invalid finish params" do
      start = "2017-12-01 13:10:01"
      finish = "2019-12-10 a"

      assert {:error, :invalid_format} = GeneralReporter.call(start, finish)
    end
  end
end
