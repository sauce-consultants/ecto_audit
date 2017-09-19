use Mix.Config

config :ecto_audit, EctoAudit,
  repo: EctoAudit.Test.Repo

config :ecto_audit, ecto_repos: [EctoAudit.Test.Repo]

config :ecto_audit, EctoAudit.Test.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "ecto_audit_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  priv: "priv/test"