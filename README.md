# EctoAudit

Ecto extensions to support auditing data changes in your Schema.


## Installation

Add EctoAudit as a dependency in your `mix.exs` file.

```
defp deps do
  [
    {:ecto_audit, "~> 0.1.0"}
  ]
end
```

After you are done, run `mix deps.get` to fetch the dependencies.

## TODO

[ ] Add mix commands to automate adding the Migration/Schema files

## Usage

### Update your Repo

Add the line `use EctoAudit.Repo` to your Ecto Repo file to import the EctoAudit functionality to your project.

```elixir
defmodule MyApp.Repo do
  use Ecto.Repo, otp_app: :my_app
  use EctoAudit.Repo
end
```

### Add Migrations for each auditable schema

The following migration is required to store the changes to your schema. In this example the Schema is called "people", but you will need to update this to reflect the name of the schema you wish to keep track of.

```elixir
defmodule MyApp.Repo.Migrations.CreateUserHistory do
  use Ecto.Migration

  def change do
    create table(:users_history) do
      add :user_id, :integer
      add :changes, :map
      add :committed_by, :integer
      add :committed_at, :utc_datetime

      timestamps()
    end

  end
end

```

### Add History Schema for each auditable schema

As per the migration above, a schema similar to the following will be required for each auditable schema.

```elixir
defmodule MyApp.UserHistory do
  use Ecto.Schema
  import Ecto.Changeset
  alias MyApp.UserHistory

  schema "users_history" do
    field :user_id, :integer
    field :changes, :map
    field :committed_at, :utc_datetime
    field :committed_by, :integer

    timestamps()
  end

  @doc false
  def changeset(%UserHistory{} = user_history, attrs) do
    user_history
    |> cast(attrs, [:user_id, :changes, :committed_by, :committed_at])
    |> validate_required([:user_id, :changes, :committed_by, :committed_at])
  end
end
```

### Perform audited Inserts / Updates

To audit the inserts / updates in project you can now use the `Repo.audited_insert` and `Repo.audited_update` functions. These will both perform inserts/updates as normal but will also insert a log of the changes (and the user who made them) to the `_history` tables created earlier.
