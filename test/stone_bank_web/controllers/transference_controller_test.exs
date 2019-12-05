defmodule StoneBankWeb.TransferenceControllerTest do
  use StoneBankWeb.ConnCase, async: true

  import Mox
  import StoneBank.Fixtures.Accounts
  import StoneBankWeb.Shared.AuthorizationShared

  alias Ecto.UUID
  alias Ecto.Changeset
  alias StoneBank.Accounts.Account
  alias StoneBank.Accounts.TransactionFactories.TransferenceFactoryMock

  @user_salt Application.get_env(:stone_bank, :user_salt)

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  setup :verify_on_exit!

  describe "create transference" do
    test_authentication_required_for(:post, :transference_path, :create)

    test "renders transference when data is valid", %{conn: conn} do
      value = 1000
      account_id = UUID.generate()
      outbound_transaction = fixture(:transaction, account_id: account_id)
      inbound_transaction = fixture(:transaction, account_id: account_id)
      destination_account_number = 5
      attrs = %{value: value, destination_account_number: destination_account_number}
      token = Phoenix.Token.sign(StoneBankWeb.Endpoint, @user_salt, account_id)

      expect(
        TransferenceFactoryMock,
        :call,
        fn ^account_id, ^destination_account_number, ^value ->
          {:ok, {outbound_transaction, inbound_transaction}}
        end
      )

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(Routes.transference_path(conn, :create), attrs)

      assert data = json_response(conn, 201)["data"]
      assert data["id"] == outbound_transaction.id
      assert data["action"] == outbound_transaction.action
      assert data["kind"] == outbound_transaction.kind
      assert data["value"] == outbound_transaction.value
      assert data["error"] == outbound_transaction.error
      assert data["processed_at"] == NaiveDateTime.to_iso8601(outbound_transaction.processed_at)
      assert data["inserted_at"] == NaiveDateTime.to_iso8601(outbound_transaction.inserted_at)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      changeset_error =
        %Account{}
        |> Changeset.change(%{})
        |> Changeset.add_error(:value, "can't be blank", validation: :required)

      account_id = UUID.generate()
      attrs = %{value: nil, destination_account_number: nil}
      token = Phoenix.Token.sign(StoneBankWeb.Endpoint, @user_salt, account_id)

      expect(TransferenceFactoryMock, :call, fn ^account_id, nil, nil ->
        {:error, changeset_error}
      end)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(Routes.transference_path(conn, :create), attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when destination account is not found", %{conn: conn} do
      account_id = UUID.generate()
      attrs = %{value: 1, destination_account_number: 1}
      token = Phoenix.Token.sign(StoneBankWeb.Endpoint, @user_salt, account_id)

      expect(TransferenceFactoryMock, :call, fn ^account_id, 1, 1 ->
        {:error, :destination_account_not_found}
      end)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(Routes.transference_path(conn, :create), attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when unavailable limit", %{conn: conn} do
      account_id = UUID.generate()
      attrs = %{value: 1, destination_account_number: 1}
      token = Phoenix.Token.sign(StoneBankWeb.Endpoint, @user_salt, account_id)

      expect(TransferenceFactoryMock, :call, fn ^account_id, 1, 1 ->
        {:error, :unavailable_limit}
      end)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(Routes.transference_path(conn, :create), attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when data is empty", %{conn: conn} do
      account_id = UUID.generate()
      token = Phoenix.Token.sign(StoneBankWeb.Endpoint, @user_salt, account_id)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(Routes.transference_path(conn, :create), %{})

      assert json_response(conn, 400)["errors"] != %{}
    end
  end
end
