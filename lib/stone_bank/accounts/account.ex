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
    |> validate()
  end

  def check_password(account, password) do
    Argon2.check_pass(account, password)
  end

  def check_available_limit(account, value) do
    if account.total >= value do
      {:ok, account}
    else
      {:error, :unavailable_limit}
    end
  end

  def apply_inbound(data, value) do
    total = change(data) |> get_field(:total)

    data
    |> change(%{total: total + value})
    |> validate()
  end

  def apply_outbound(data, value) do
    total = change(data) |> get_field(:total)

    data
    |> change(%{total: total - value})
    |> validate()
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{changes: %{password: pass}} ->
        change(changeset, Argon2.add_hash(pass))

      _ ->
        changeset
    end
  end

  defp validate(changeset) do
    changeset
    |> validate_length(:password, min: 6)
    |> validate_number(:total, greater_than_or_equal_to: 0)
    |> put_password_hash()
    |> validate_required([:name, :password_hash])
  end
end
