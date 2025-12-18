defmodule HeadsUp.Schema do
  defmacro __using__(opts) do
    prefix = Keyword.fetch!(opts, :prefix)

    quote do
      use Ecto.Schema

      # Configuration automatique de l'ID préfixé
      @primary_key {:id, HeadsUp.Ecto.PrefixedId, autogenerate: true, prefix: unquote(prefix)}

      # Les clés étrangères pointeront aussi vers des strings par défaut
      @foreign_key_type :string

      # (Optionnel) Ajout automatique de timestamps avec configuration microseconde si besoin
      @timestamps_opts [type: :utc_datetime_usec]

      import Ecto.Changeset
      import Ecto.Query
    end
  end
end
