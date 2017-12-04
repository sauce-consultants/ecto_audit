defmodule EctoAudit.Test.Repo.Migrations do
  use Ecto.Migration

  def up do
    create_if_not_exists table(:users) do
      add :name, :string
      add :email, :string
      add :postcode, :string
      add :password, :string
      
      timestamps()
    end

    create table(:users_history) do
      add :user_id, :integer
      add :changes, :map
      add :committed_by, :integer
      add :committed_at, :utc_datetime

      timestamps()
    end
  end

  def down do
    drop table(:users)
    drop table(:users_history)
  end
end
