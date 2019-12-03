defmodule StoneBank.ChangesetHelperTest do
  use ExUnit.Case

  alias StoneBank.ChangesetHelper

  describe "check_changeset/1" do
    test "returns ok" do
      assert {:ok, %Ecto.Changeset{} = changeset} =
               ChangesetHelper.check_changeset(%Ecto.Changeset{valid?: true})
    end

    test "returns error" do
      assert {:error, %Ecto.Changeset{} = changeset} =
               ChangesetHelper.check_changeset(%Ecto.Changeset{valid?: false})
    end
  end
end
