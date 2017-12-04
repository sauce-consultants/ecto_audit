defmodule EctoAuditTest do
  use EctoAudit.Test.DataCase
  doctest EctoAudit

  #
  # Test Scemas
  #

	defmodule User do
	  use Ecto.Schema
	  import Ecto.Changeset

	  schema "users" do
	    field :email, :string
	    field :name, :string
      field :postcode, :string
      field :password, :string

	    timestamps()
	  end

	  @doc false
	  def changeset(%EctoAuditTest.User{} = user, attrs) do
	    user
	    |> cast(attrs, [:name, :email, :postcode, :password])
	    |> validate_required([:name, :email, :postcode])
	  end
	end

	defmodule UserHistory do
	  use Ecto.Schema
	  import Ecto.Changeset

	  schema "users_history" do
	    field :committed_at, :utc_datetime
	    field :committed_by, :integer
	    field :changes, :map
	    field :user_id, :integer

	    timestamps()
	  end

	  @doc false
	  def changeset(%EctoAuditTest.UserHistory{} = user_history, attrs) do
	    user_history
	    |> cast(attrs, [:user_id, :changes, :committed_by, :committed_at])
	    |> validate_required([:user_id, :changes, :committed_by, :committed_at])
	  end
	end


	#
	# Test Logic
	#


  @valid_params %{email: "test@test.com", name: "Tommy Tester", postcode: "HU1 1UU", password: "password"}

  test "inserting a user" do
  	{:ok, user} =
	  	%EctoAuditTest.User{}
	  	|> EctoAuditTest.User.changeset(@valid_params)
			|> Repo.audited_insert(1)

    user_history = Repo.all(EctoAuditTest.UserHistory) |> List.first

    assert user_history.changes["password"] == "******"

		{:ok, user} =
	  	user
	  	|> EctoAuditTest.User.changeset(%{name: "Matt Weldon"})
			|> Repo.audited_update(1)

		{:ok, user} =
	  	user
	  	|> EctoAuditTest.User.changeset(%{postcode: "HU2 2EE", password: "anotherpassword"})
			|> Repo.audited_update(1)

		assert user
    
    user_histories = Repo.all(EctoAuditTest.UserHistory)

    user_history = user_histories |> List.last

    assert user_history.changes["password"] == "******"
    
    assert user_histories |> Enum.count == 3
  end

  test "receiving a validation error when inserting a user" do
  	{:error, changeset} =
	  	%EctoAuditTest.User{}
	  	|> EctoAuditTest.User.changeset(%{})
			|> Repo.audited_insert(1)

		assert changeset
  end
end
