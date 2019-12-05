# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :stone_bank,
  children: [
    StoneBank.Repo,
    StoneBankWeb.Endpoint,
    StoneBank.Accounts.TransactionServer
  ],
  token_max_age: 3_600,
  user_salt: "J4gZROHg7ryJgCJAtMqR6GwvmIuUDoICmB1q+znzcu2alExmDIuI9VOjF7EZDz8J",
  gift_value: 100_000,
  time_module: StoneBank.Time,
  accounts_module: StoneBank.Accounts,
  general_reporter_module: StoneBank.Accounts.Reporters.GeneralReporter,
  gift_transaction_factory: StoneBank.Accounts.TransactionFactories.GiftFactory,
  transference_transaction_factory: StoneBank.Accounts.TransactionFactories.TransferenceFactory,
  withdrawal_transaction_factory: StoneBank.Accounts.TransactionFactories.WithdrawalFactory,
  transaction_processors: %{
    "gift" => StoneBank.Accounts.TransactionProcessors.GiftProcessor,
    "withdrawal" => StoneBank.Accounts.TransactionProcessors.WithdrawalProcessor,
    "transference" => StoneBank.Accounts.TransactionProcessors.TransferenceProcessor
  },
  transaction_notificators: %{
    "gift" => StoneBank.Accounts.TransactionNotificators.DefaultNotificator,
    "withdrawal" => StoneBank.Accounts.TransactionNotificators.DefaultNotificator,
    "transference" => StoneBank.Accounts.TransactionNotificators.DefaultNotificator
  }

config :stone_bank,
  ecto_repos: [StoneBank.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :stone_bank, StoneBankWeb.Endpoint,
  url: [host: "localhost"],
  http: [port: System.get_env("PORT") || "4000"],
  secret_key_base: "J4gZROHg7ryJgCJAtMqR6GwvmIuUDoICmB1q+znzcu2alExmDIuI9VOjF7EZDz8J",
  render_errors: [view: StoneBankWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: StoneBank.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
