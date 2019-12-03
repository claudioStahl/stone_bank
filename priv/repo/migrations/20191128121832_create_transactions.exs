defmodule StoneBank.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :group_id, :string
      add :action, :string
      add :kind, :string
      add :value, :bigint
      add :processed_at, :utc_datetime
      add :error, :string
      add :account_id, references(:accounts, on_delete: :restrict, type: :binary_id)

      timestamps()
    end

    create index(:transactions, [:account_id])
  end
end
