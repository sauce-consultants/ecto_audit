defmodule EctoAudit.Auditable do

  defmacro __using__(opts) do
    quote do
      alias unquote(opts[:repo])

      def audit_module, do: Module.concat(["#{__MODULE__}Audit"])
      def auditable_record_id do
        "#{__MODULE__ |> Module.split |> List.last |> EctoAudit.Utils.underscore}_id"
        |> String.downcase
        |> String.to_atom
      end

      def insert(changeset) do
        changeset
        |> Repo.insert
        |> track
      end

      def update(changeset) do
        changeset
        |> Repo.update
        |> track
      end

      def delete(changeset) do
        changeset
        |> Repo.delete
        |> track
      end

      def track({:ok, record}) do
        render_existing_record_inactive
        insert_new_audit_record(record)
        {:ok, record}
      end
      def track(error), do: error

      defp render_existing_record_inactive do
        from(a in audit_module, where: a.inactive_at == ^EctoAudit.Auditable.eot)
        |> Repo.update_all(set: [inactive_at: EctoAudit.Auditable.now])
      end

      defp insert_new_audit_record(record) do
        audit =
          record
          |> Map.from_struct
          |> Map.put(auditable_record_id, record.id)
          |> Map.put(:effective_at, EctoAudit.Auditable.now)
          |> Map.put(:inactive_at, EctoAudit.Auditable.eot)

        audit_module.changeset(audit_module.__struct__, audit)
        |> Repo.insert
      end
    end
  end

  #
  # Helper Methods
  #

  def now do
    Ecto.DateTime.utc
  end

  def eot do
    {:ok, eot} = Ecto.DateTime.load({{9999, 12, 31}, {23, 59, 59}})
    eot
  end

end
