defmodule StoneBankWeb.WithdrawalControllerTest do
  use StoneBankWeb.ConnCase, async: true

  import Mox
  import StoneBank.Fixtures.Accounts
  import StoneBankWeb.Shared.AuthorizationShared

  alias Ecto.UUID
  alias Ecto.Changeset
  alias StoneBank.Accounts.Account
  alias StoneBank.Accounts.TransactionFactories.WithdrawalFactoryMock

  @user_salt Application.get_env(:stone_bank, :user_salt)

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  setup :verify_on_exit!

  describe "create withdrawal" do
    test_authentication_required_for(:post, :withdrawal_path, :create)

    test "renders transference when data is valid", %{conn: conn} do
      value = 1000
      account_id = UUID.generate()
      transaction = fixture(:transaction, account_id: account_id)
      token = Phoenix.Token.sign(StoneBankWeb.Endpoint, @user_salt, account_id)
      expect(WithdrawalFactoryMock, :call, fn ^account_id, ^value -> {:ok, transaction} end)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(Routes.withdrawal_path(conn, :create), %{value: value})

      assert data = json_response(conn, 201)["data"]
      assert data["id"] == transaction.id
      assert data["action"] == transaction.action
      assert data["kind"] == transaction.kind
      assert data["value"] == transaction.value
      assert data["error"] == transaction.error
      assert data["processed_at"] == NaiveDateTime.to_iso8601(transaction.processed_at)
      assert data["inserted_at"] == NaiveDateTime.to_iso8601(transaction.inserted_at)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      changeset_error =
        %Account{}
        |> Changeset.change(%{})
        |> Changeset.add_error(:value, "can't be blank", validation: :required)

      account_id = UUID.generate()
      token = Phoenix.Token.sign(StoneBankWeb.Endpoint, @user_salt, account_id)
      expect(WithdrawalFactoryMock, :call, fn ^account_id, nil -> {:error, changeset_error} end)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(Routes.withdrawal_path(conn, :create), %{value: nil})

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when unavailable limit", %{conn: conn} do
      account_id = UUID.generate()
      attrs = %{value: 1}
      token = Phoenix.Token.sign(StoneBankWeb.Endpoint, @user_salt, account_id)
      expect(WithdrawalFactoryMock, :call, fn ^account_id, 1 -> {:error, :unavailable_limit} end)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(Routes.withdrawal_path(conn, :create), attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when data is empty", %{conn: conn} do
      account_id = UUID.generate()
      token = Phoenix.Token.sign(StoneBankWeb.Endpoint, @user_salt, account_id)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(Routes.withdrawal_path(conn, :create), %{})

      assert json_response(conn, 400)["errors"] != %{}
    end
  end
end
