# To migrate db execute this with a release:
# _build/prod/rel/stone_bank/bin/stone_bank eval "StoneBank.Release.migrate"
#
# To rollback db execute this with a release:
# _build/prod/rel/stone_bank/bin/stone_bank eval "StoneBank.Release.rollback(20190610235113)"
#
defmodule StoneBank.Release do
  @app :stone_bank

  def migrate do
    load()
    {:ok, _, _} = Ecto.Migrator.with_repo(StoneBank.Repo, &Ecto.Migrator.run(&1, :up, all: true))
  end

  def rollback(version) do
    load()

    {:ok, _, _} =
      Ecto.Migrator.with_repo(StoneBank.Repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp load do
    Application.load(@app)
  end
end
