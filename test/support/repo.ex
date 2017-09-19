defmodule EctoAudit.Test.Repo do
  use Ecto.Repo, otp_app: :ecto_audit
  use EctoAudit.Repo

  def log(_cmd), do: nil
end