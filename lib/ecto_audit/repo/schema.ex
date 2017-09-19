defmodule EctoAudit.Repo.Schema do
	alias Ecto.Multi


	@doc """
  Inserts the given changeset and stores a record of the fielda using the related
  History schema.
  """
  def audited_insert(repo, changeset, user_id, opts \\ []) do
		begin_transaction
		|> save_changeset(changeset, :insert)
		|> audit_changes(repo, changeset, user_id)
		|> commit_transaction(repo)
  end


  @doc """
  Updates the given changeset and stores a record of the changes in the related
  History schema.
  """
  def audited_update(repo, changeset, user_id, opts \\ []) do
		begin_transaction
		|> save_changeset(changeset, :update)
		|> audit_changes(repo, changeset, user_id)
		|> commit_transaction(repo)
  end


  @doc """
  Creates a new Multi to be used to wrap later commands in a transaction
  """
  defp begin_transaction do
  	Multi.new
	end


	@doc """
	Saves the changeset according to the atom given in the last parameter
	"""
	defp save_changeset(multi, changeset, :insert) do
		multi |> Multi.insert(:save, changeset)
	end
	defp save_changeset(multi, changeset, :update) do
		multi
		|> Multi.update(:save, changeset)
	end


	@doc """
	Inserts a new History record containing the changes within the changeset
	provided.
	"""
	defp audit_changes(multi, repo, changeset, user_id) do
		multi
		|> Multi.run(:audit, fn (result) -> 
			case result do
				%{save: struct} ->
					insert_audit(repo, struct, changeset, user_id)
				otherwise -> 
					otherwise
			end
		end)
	end


	@doc """
	Commits the transacation to the database and returns the following tuple
	if successful:

		{:ok, struct}

	"""
	defp commit_transaction(multi, repo) do
		multi
		|> repo.transaction
		|> case do
			{:ok, %{save: record}} ->
				{:ok, record}
			otherwise ->
				otherwise
		end
	end

	@doc """
	Builds a changeset for the *History module associated with the changeset
	and then insert it.

	Returns the original saved record as part of a tuple if successful, and
	passes the error on if anything fails.
	"""
	defp insert_audit(repo, struct, changeset, user_id) do
    history_module = changeset |> history_module
    history_struct = history_module |> struct

    history_struct
    |> history_module.changeset(%{
      "committed_at" => DateTime.utc_now,
      "committed_by" => user_id,
      "changes" => changeset.changes,
      "#{changeset |> schema_key}_id" => struct.id,
    })
    |> repo.insert
    |> case do
  		{:ok, _} -> {:ok, struct}
  		otherwise -> otherwise
  	end
	end

	defp schema_key(changeset) do
		changeset
		|> schema_module
		|> Macro.underscore
		|> String.split("/")
		|> List.last
	end

	defp schema_module(changeset) do
		"Elixir." <> struct_name = Atom.to_string(changeset.data.__struct__)
		struct_name
	end

  defp history_module(changeset) do 
  	Module.concat(["#{changeset |> schema_module}History"])
  end


end