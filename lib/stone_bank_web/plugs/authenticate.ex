defmodule StoneBankWeb.Plugs.Authenticate do
  import Plug.Conn
  import Phoenix.Controller
  import StoneBankWeb.Gettext

  alias Phoenix.Token

  @user_salt Application.get_env(:stone_bank, :user_salt)
  @token_max_age Application.get_env(:stone_bank, :token_max_age)

  def init(default), do: default

  def call(conn, _default) do
    with {:ok, token} <- extract_token(conn),
         {:ok, account_id} <-
           Token.verify(StoneBankWeb.Endpoint, @user_salt, token, max_age: @token_max_age) do
      authorized(conn, account_id)
    else
      {:error, :missing_auth_header} -> unauthorized(conn, gettext("Missing auth header"))
      {:error, :token_not_found} -> unauthorized(conn, gettext("Token not found"))
      {:error, :expired} -> unauthorized(conn, gettext("Expired token"))
      {:error, :invalid} -> unauthorized(conn, gettext("Invalid token"))
    end
  end

  defp extract_token(conn) do
    case get_req_header(conn, "authorization") do
      [auth_header] -> get_token_from_header(auth_header)
      _ -> {:error, :missing_auth_header}
    end
  end

  defp get_token_from_header(auth_header) do
    {:ok, reg} = Regex.compile("Bearer\:?\s+(.*)$", "i")

    case Regex.run(reg, auth_header) do
      [_, match] -> {:ok, String.trim(match)}
      _ -> {:error, :token_not_found}
    end
  end

  defp authorized(conn, account_id) do
    conn
    |> assign(:signed_in, true)
    |> assign(:signed_account_id, account_id)
  end

  defp unauthorized(conn, message) do
    conn
    |> put_status(:unauthorized)
    |> put_view(StoneBankWeb.ErrorView)
    |> render("message.json", message: message)
    |> halt()
  end
end
