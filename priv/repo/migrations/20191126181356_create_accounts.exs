defmodule StoneBank.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :number, :serial
      add :name, :string
      add :total, :bigint, default: 0
      add :password_hash, :string

      timestamps()
    end

    create unique_index(:accounts, [:number])
  end
end
