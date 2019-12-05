defmodule StoneBankWeb.GeneralReporterView do
  use StoneBankWeb, :view

  def render("index.json", %{data: data}) do
    %{data: data}
  end
end
