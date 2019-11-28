defmodule StoneBank.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :name, :string
    field :number, :integer
    field :password_hash, :string
    field :total, :integer, default: 0
    field :password, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name, :total, :password])
    |> validate_length(:password, min: 6)
    |> validate_number(:total, greater_than_or_equal_to: 0)
    |> put_password_hash()
    |> validate_required([:name, :password_hash])
  end

  def check_password(account, password) do
    Argon2.check_pass(account, password)
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{changes: %{password: pass}} ->
        change(changeset, Argon2.add_hash(pass))

      _ ->
        changeset
    end
  end
end
