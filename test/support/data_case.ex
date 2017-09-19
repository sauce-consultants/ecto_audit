defmodule EctoAudit.Test.DataCase do
  use ExUnit.CaseTemplate
  alias EctoAudit.Test.Repo

  using(_opts) do
    quote do
      import EctoAudit.Test.DataCase
      alias EctoAudit.Test.Repo
    end
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    :ok
  end
end