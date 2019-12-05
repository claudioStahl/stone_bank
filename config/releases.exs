import Config

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

config :stone_bank, StoneBank.Repo,
  # ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

url_scheme = System.get_env("URL_SCHEME") || "http"
url_host = System.get_env("URL_HOST") || "localhost"
url_port = System.get_env("URL_PORT") || "80"
force_ssl = if url_scheme == "https", do: [rewrite_on: [:x_forwarded_proto]], else: []

config :stone_bank, StoneBankWeb.Endpoint,
  load_from_system_env: true,
  url: [scheme: url_scheme, host: url_host, port: url_port],
  force_ssl: force_ssl,
  secret_key_base: secret_key_base
