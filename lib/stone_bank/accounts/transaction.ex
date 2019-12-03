defmodule StoneBank.Accounts.Transaction do
  use Ecto.Schema

  import Ecto.Changeset

  @time_module Application.get_env(:stone_bank, :time_module)
  @errors ["unavailable_limit"]
  @kinds ["inbound", "outbound"]
  @actions ["gift", "withdrawal", "transference"]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "transactions" do
    field :error, :string
    field :group_id, :string
    field :action, :string
    field :kind, :string
    field :processed_at, :naive_datetime
    field :value, :integer
    field :account_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [
      :account_id,
      :group_id,
      :action,
      :kind,
      :value,
      :processed_at,
      :error,
      :inserted_at
    ])
    |> validate()
  end

  def mark_processed(data) do
    processed_at = @time_module.naive_date_time_utc_now()

    change(data, %{processed_at: processed_at})
    |> validate()
  end

  def add_error(data, error) when is_binary(error) do
    change(data, %{error: error})
    |> validate()
  end

  defp validate(changeset) do
    changeset
    |> validate_required([:account_id, :action, :kind, :value])
    |> validate_inclusion(:error, @errors)
    |> validate_inclusion(:action, @actions)
    |> validate_inclusion(:kind, @kinds)
    |> validate_number(:value, greater_than_or_equal_to: 0)
  end
end
