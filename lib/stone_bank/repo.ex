defmodule StoneBank.Repo do
  use Ecto.Repo,
    otp_app: :stone_bank,
    adapter: Ecto.Adapters.Postgres
end
