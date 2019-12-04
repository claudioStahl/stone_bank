defmodule StoneBank.Repo.Migrations.CreateNotifyTransactionsChanges do
  use Ecto.Migration

  def up do
    execute "CREATE OR REPLACE FUNCTION notify_new_transaction()
      RETURNS trigger AS $$
      BEGIN
        PERFORM pg_notify(
          'new_transaction',
          json_build_object(
            'operation', TG_OP,
            'record', row_to_json(NEW)
          )::text
        );

        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;"

    execute "CREATE TRIGGER new_transaction
      AFTER INSERT
      ON transactions
      FOR EACH ROW
      EXECUTE PROCEDURE notify_new_transaction()"
  end

  def down do
    execute "DROP TRIGGER IF EXISTS new_transaction ON transactions;"

    execute "DROP FUNCTION IF EXISTS notify_new_transaction;"
  end
end
