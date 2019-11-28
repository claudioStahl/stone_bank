defmodule StoneBankWeb.AuthView do
  use StoneBankWeb, :view

  def render("show.json", %{token: token}) do
    %{data: %{token: token}}
  end
end
