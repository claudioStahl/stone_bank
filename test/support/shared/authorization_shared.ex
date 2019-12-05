defmodule StoneBankWeb.Shared.AuthorizationShared do
  alias StoneBankWeb.Router

  import Plug.Conn
  import Phoenix.ConnTest

  defmacro test_authentication_required_for(method, path_name, action) do
    quote do
      test "requires authentication", %{conn: conn} do
        method = unquote(method)
        path_name = unquote(path_name)
        action = unquote(action)

        assert send_invalid_token(conn, @endpoint, method, path_name, action)
        assert send_empty_token(conn, @endpoint, method, path_name, action)
        assert send_empty_authorization(conn, @endpoint, method, path_name, action)
      end
    end
  end

  def send_invalid_token(conn, endpoint, method, path_name, action) do
    path = apply(Router.Helpers, path_name, [conn, action])

    conn
    |> put_req_header("authorization", "Bearer abc")
    |> dispatch(endpoint, method, path, nil)
    |> json_response(401)
  end

  def send_empty_token(conn, endpoint, method, path_name, action) do
    path = apply(Router.Helpers, path_name, [conn, action])

    conn
    |> put_req_header("authorization", "")
    |> dispatch(endpoint, method, path, nil)
    |> json_response(401)
  end

  def send_empty_authorization(conn, endpoint, method, path_name, action) do
    path = apply(Router.Helpers, path_name, [conn, action])

    conn
    |> dispatch(endpoint, method, path, nil)
    |> json_response(401)
  end
end
