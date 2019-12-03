# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :stone_bank,
  token_max_age: 3_600,
  user_salt: "J4gZROHg7ryJgCJAtMqR6GwvmIuUDoICmB1q+znzcu2alExmDIuI9VOjF7EZDz8J",
  gift_value: 100_000,
  time_module: StoneBank.Time,
  accounts_module: StoneBank.Accounts,
  gift_transaction_factory: StoneBank.Accounts.TransactionFactories.GiftFactory,
  transference_transaction_factory: StoneBank.Accounts.TransactionFactories.TransferenceFactory,
  withdrawal_transaction_factory: StoneBank.Accounts.TransactionFactories.WithdrawalFactory

config :stone_bank,
  ecto_repos: [StoneBank.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :stone_bank, StoneBankWeb.Endpoint,
  url: [host: "localhost"],
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
