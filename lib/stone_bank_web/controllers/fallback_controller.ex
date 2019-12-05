defmodule StoneBankWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use StoneBankWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(StoneBankWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(StoneBankWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:unprocessable_entity, message}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(StoneBankWeb.ErrorView)
    |> render("message.json", message: message)
  end

  def call(conn, {:bad_request, message}) do
    conn
    |> put_status(:bad_request)
    |> put_view(StoneBankWeb.ErrorView)
    |> render("message.json", message: message)
  end

  def call(conn, {:unauthorized, message}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(StoneBankWeb.ErrorView)
    |> render("message.json", message: message)
  end
end
