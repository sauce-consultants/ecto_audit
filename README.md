# EctoAudit

Ecto extension to support auditing data changes in your Schema.

** NOTE: The process around this is a little convoluted at the moment. Very much WIP. **

## Installation

Add EctoAudit as a dependency in your `mix.exs` file.

```
defp deps do
  [
    {:ecto_audit, "~> 0.0.1"}
  ]
end
```

After you are done, run mix deps.get in your shell to fetch the dependencies.

## Usage

In each Ecto Schema you wish to audit, add the following line:

```
defmodule User do
  use Ecto.Model
  use EctoAudit.Auditable, repo: YourApp.Repo # << This line required for each Schema to be audited.

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :submitted_by, :integer

    timestamps
  end
end
```

Then, create a corresponding "Audit" schema containing the fields to be tracked from the "main" schema. This must also have `*_id`, `effective_at` and `inactive_at` fields to aid with the auditing process.

```
defmodule UserAudit do
  use Ecto.Model

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :submitted_by, :integer

    field :user_id, :integer
    field :effective_at, Ecto.DateTime
    field :inactive_at, Ecto.DateTime
  end
end
```

Finally, when performing Inserts, Updates or Deletes to the primary schema replace `Repo.{insert|update|delete}` with `User.{insert|update|delete}`.
