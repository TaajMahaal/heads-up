defmodule HeadsUp.Ecto.PrefixedId do
  use Ecto.ParameterizedType

  @impl true
  def init(opts) do
    prefix = Keyword.get(opts, :prefix)
    unless is_binary(prefix), do: raise(ArgumentError, "Option :prefix required")
    %{prefix: prefix}
  end

  @impl true
  def type(_params), do: :string

  @impl true
  def autogenerate(%{prefix: prefix}) do
    "#{prefix}_#{Ecto.ULID.generate()}"
  end

  @impl true
  def cast(data, %{prefix: prefix}) when is_binary(data) do
    with true <- String.starts_with?(data, prefix <> "_"),
         [_prefix, ulid_part] <- String.split(data, "_", parts: 2),
         true <- String.length(ulid_part) == 26 do
      {:ok, data}
    else
      _ -> {:error, [message: "must be in format #{prefix}_<26-char-ulid>"]}
    end
  end

  def cast(_data, _), do: :error

  @impl true
  def load(data, _loader, _params), do: {:ok, data}

  @impl true
  def dump(data, _dumper, _params), do: {:ok, data}

  @impl true
  def equal?(a, b, _params), do: a == b
end
