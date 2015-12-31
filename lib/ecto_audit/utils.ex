defmodule EctoAudit.Utils do
  def underscore(atom) when is_atom(atom) do
      "Elixir." <> rest = Atom.to_string(atom)
      underscore(rest)
    end

    def underscore(""), do: ""

    def underscore(<<h, t :: binary>>) do
      <<to_lower_char(h)>> <> do_underscore(t, h)
    end

    defp do_underscore(<<h, t, rest :: binary>>, _) when h in ?A..?Z and not (t in ?A..?Z or t == ?.) do
      <<?_, to_lower_char(h), t>> <> do_underscore(rest, t)
    end

    defp do_underscore(<<h, t :: binary>>, prev) when h in ?A..?Z and not prev in ?A..?Z do
      <<?_, to_lower_char(h)>> <> do_underscore(t, h)
    end

    defp do_underscore(<<?., t :: binary>>, _) do
      <<?/>> <> underscore(t)
    end

    defp do_underscore(<<h, t :: binary>>, _) do
      <<to_lower_char(h)>> <> do_underscore(t, h)
    end

    defp do_underscore(<<>>, _) do
      <<>>
    end

    defp to_lower_char(char) when char in ?A..?Z, do: char + 32
    defp to_lower_char(char), do: char

end
