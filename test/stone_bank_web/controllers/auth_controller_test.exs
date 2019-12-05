defmodule StoneBankWeb.AuthControllerTest do
  use StoneBankWeb.ConnCase, async: true

  import Mox
  import StoneBank.Fixtures.Accounts

  alias StoneBank.AccountsMock

  @user_salt Application.get_env(:stone_bank, :user_salt)
  @attrs %{number: 1, password: "123456"}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  setup :verify_on_exit!

  describe "login" do
    test "renders token when data is valid", %{conn: conn} do
      account = fixture(:account)
      expect(AccountsMock, :get_account_by_number_and_password, fn _, _ -> {:ok, account} end)
      conn = post(conn, Routes.auth_path(conn, :create), @attrs)
      assert %{"token" => token} = json_response(conn, 200)["data"]

      assert {:ok, account.id} ==
               Phoenix.Token.verify(StoneBankWeb.Endpoint, @user_salt, token, max_age: 1)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      expect(AccountsMock, :get_account_by_number_and_password, fn _, _ ->
        {:error, :not_found}
      end)

      conn = post(conn, Routes.auth_path(conn, :create), @attrs)
      assert json_response(conn, 401)["errors"] != %{}
    end

    test "renders errors when data is empty", %{conn: conn} do
      conn = post(conn, Routes.auth_path(conn, :create), %{})
      assert json_response(conn, 400)["errors"] != %{}
    end
  end
end
