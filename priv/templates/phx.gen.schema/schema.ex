defmodule <%= inspect schema.module %> do
  use HeadsUp.Schema, prefix: "TODO_CHANGE_ME"

  schema "<%= schema.table %>" do
<%= for {k, v} <- schema.attrs do %>    field <%= inspect k %>, <%=
    if match?({:enum, _}, v) do
      {_, opts} = schema.types[k]
      "Ecto.Enum, values: " <> inspect(opts[:values])
    else
      inspect(v)
    end %><%=
    if k in schema.redacts, do: ", redact: true", else: ""
    %><%= schema.defaults[k] %>
<% end %><%= for {k, _, _, _} <- schema.assocs do %>    field <%= inspect k %>, :string
<% end %>
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(<%= schema.singular %>, attrs) do
    <%= schema.singular %>
    |> cast(attrs, [<%= Enum.map_join(schema.attrs, ", ", &inspect(elem(&1, 0))) %>])
    |> validate_required([<%= Enum.map_join(schema.attrs, ", ", &inspect(elem(&1, 0))) %>])
  end
end
