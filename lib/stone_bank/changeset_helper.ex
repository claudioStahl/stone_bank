defmodule StoneBank.ChangesetHelper do
  def check_changeset(changeset) do
    if changeset.valid? do
      {:ok, changeset}
    else
      {:error, changeset}
    end
  end
end
