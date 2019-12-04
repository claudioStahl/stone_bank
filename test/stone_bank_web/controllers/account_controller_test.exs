defmodule StoneBankWeb.AccountControllerTest do
  use StoneBankWeb.ConnCase, async: true

  import Mox
  import StoneBank.Fixtures.Accounts

  alias Ecto.Changeset
  alias StoneBank.AccountsMock
  alias StoneBank.Accounts.Account

  @create_attrs %{name: "some name", password: "some_password"}
  @invalid_attrs %{name: nil, password: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  setup :verify_on_exit!

  describe "create account" do
    test "renders account when data is valid", %{conn: conn} do
      account = fixture(:account)
      expect(AccountsMock, :create_account, fn _, _ -> {:ok, account} end)
      conn = post(conn, Routes.account_path(conn, :create), @create_attrs)
      %Account{id: id, name: name, number: number, total: total} = account

      assert %{
               "id" => ^id,
               "name" => ^name,
               "number" => ^number,
               "total" => ^total
             } = json_response(conn, 201)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      changeset_error =
        %Account{}
        |> Changeset.change(@invalid_attrs)
        |> Changeset.add_error(:name, "can't be blank", validation: :required)

      expect(AccountsMock, :create_account, fn _, _ -> {:error, changeset_error} end)
      conn = post(conn, Routes.account_path(conn, :create), @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
