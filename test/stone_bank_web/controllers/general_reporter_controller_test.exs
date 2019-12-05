defmodule StoneBankWeb.GeneralReporterControllerTest do
  use StoneBankWeb.ConnCase, async: true

  import Mox

  alias StoneBank.Accounts.Reporters.GeneralReporterMock

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  setup :verify_on_exit!

  describe "get report" do
    test "renders report when data is valid", %{conn: conn} do
      start = "2017-12-01 13:10:01"
      finish = "2019-12-10 13:10:01"
      report = %{"days" => [], "years" => [], "months" => [], "total" => []}
      attrs = %{start: start, finish: finish}

      expect(GeneralReporterMock, :call, fn ^start, ^finish -> {:ok, report} end)
      conn = get(conn, Routes.general_reporter_path(conn, :index), attrs)

      assert report == json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      start = "2017-12-01 bbb"
      finish = "2019-12-10 aaa"
      attrs = %{start: start, finish: finish}

      expect(GeneralReporterMock, :call, fn ^start, ^finish -> {:error, :invalid_format} end)
      conn = get(conn, Routes.general_reporter_path(conn, :index), attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
