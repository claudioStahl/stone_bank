use Mix.Config

config :stone_bank,
  time_module: StoneBank.TimeMock,
  accounts_module: StoneBank.AccountsMock,
  gift_transaction_factory: StoneBank.Accounts.TransactionFactories.GiftFactoryMock,
  transference_transaction_factory:
    StoneBank.Accounts.TransactionFactories.TransferenceFactoryMock,
  withdrawal_transaction_factory: StoneBank.Accounts.TransactionFactories.WithdrawalFactoryMock

# Configure your database
config :stone_bank, StoneBank.Repo,
  username: "postgres",
  password: "postgres",
  database: "stone_bank_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :stone_bank, StoneBankWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
