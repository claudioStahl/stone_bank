defmodule StoneBankWeb.AccountView do
  use StoneBankWeb, :view
  alias StoneBankWeb.AccountView

  def render("show.json", %{account: account}) do
    %{data: render_one(account, AccountView, "account.json")}
  end

  def render("account.json", %{account: account}) do
    %{
      id: account.id,
      number: account.number,
      name: account.name,
      total: account.total
    }
  end
end
