defmodule StoneBankWeb.GeneralReporterController do
  use StoneBankWeb, :controller

  action_fallback StoneBankWeb.FallbackController

  @general_reporter_module Application.get_env(
                             :stone_bank,
                             :general_reporter_module
                           )

  def index(conn, params) do
    with {:ok, data} <- @general_reporter_module.call(params["start"], params["finish"]) do
      conn
      |> put_status(:ok)
      |> render("index.json", data: data)
    else
      {:error, :invalid_format} ->
        {:unprocessable_entity,
         gettext("Invalid date format. This is a valid example '2019-11-30T00:00:00'.")}

      error ->
        error
    end
  end
end
