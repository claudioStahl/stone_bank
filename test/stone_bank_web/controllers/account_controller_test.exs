defmodule StoneBankWeb.AccountControllerTest do
  use StoneBankWeb.ConnCase

  import Mox

  alias StoneBank.AccountsMock
  alias StoneBank.Accounts.Account

  @create_attrs %{name: "some name", password: "some_password"}
  @invalid_attrs %{name: nil, password: nil}
  @account %Account{
    id: "f123dc8d-a24f-47af-ab80-91f50ad28f3c",
    name: @create_attrs.name,
    number: 5,
    total: 0,
    password_hash: "AvO1oQD7/lx3CTDv+ryw$jDrFUEi7fMe6pVGB9fIAbEooFhvBgB/zxCsX8dCKBhI"
  }
  @changeset_error %Ecto.Changeset{
    action: :insert,
    changes: %{},
    errors: [
      name: {"can't be blank", [validation: :required]},
      password_hash: {"can't be blank", [validation: :required]}
    ],
    data: %StoneBank.Accounts.Account{},
    valid?: false,
    types: %{
      id: :binary_id,
      inserted_at: :naive_datetime,
      name: :string,
      number: :integer,
      password: :string,
      password_hash: :string,
      total: :integer,
      updated_at: :naive_datetime
    }
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  setup :verify_on_exit!

  describe "create account" do
    test "renders account when data is valid", %{conn: conn} do
      expect(AccountsMock, :create_account, fn _name, _password -> {:ok, @account} end)
      conn = post(conn, Routes.account_path(conn, :create), @create_attrs)
      %Account{id: id, name: name, number: number, total: total} = @account

      assert %{
               "id" => ^id,
               "name" => ^name,
               "number" => ^number,
               "total" => ^total
             } = json_response(conn, 201)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      expect(AccountsMock, :create_account, fn _name, _password -> {:error, @changeset_error} end)
      conn = post(conn, Routes.account_path(conn, :create), @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
