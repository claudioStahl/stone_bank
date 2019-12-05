use Mix.Config

config :stone_bank,
  children: [
    StoneBank.Repo,
    StoneBankWeb.Endpoint
  ],
  time_module: StoneBank.TimeMock,
  accounts_module: StoneBank.AccountsMock,
  general_reporter_module: StoneBank.Accounts.Reporters.GeneralReporterMock,
  gift_transaction_factory: StoneBank.Accounts.TransactionFactories.GiftFactoryMock,
  transference_transaction_factory:
    StoneBank.Accounts.TransactionFactories.TransferenceFactoryMock,
  withdrawal_transaction_factory: StoneBank.Accounts.TransactionFactories.WithdrawalFactoryMock,
  transaction_processors: %{
    "gift" => StoneBank.Accounts.TransactionProcessors.GiftProcessorMock,
    "withdrawal" => StoneBank.Accounts.TransactionProcessors.WithdrawalProcessorMock,
    "transference" => StoneBank.Accounts.TransactionProcessors.TransferenceProcessorMock
  },
  transaction_notificators: %{
    "gift" => StoneBank.Accounts.TransactionNotificators.GiftNotificatorMock,
    "withdrawal" => StoneBank.Accounts.TransactionNotificators.WithdrawalNotificatorMock,
    "transference" => StoneBank.Accounts.TransactionNotificators.TransferenceNotificatorMock
  }

# Configure your database
config :stone_bank, StoneBank.Repo,
  username: "postgres",
  password: "postgres",
  database: "stone_bank_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  queue_target: 1_000,
  queue_interval: 5_000

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :stone_bank, StoneBankWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
