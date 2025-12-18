defmodule <%= inspect schema.repo %>.Migrations.Create<%= schema.human_plural %> do
  use Ecto.Migration

  def change do
    create table(:<%= schema.table %>, primary_key: false) do
      add :id, :string, primary_key: true

<%= for {k, v} <- schema.attrs do %>      add <%= inspect k %>, <%=
      if match?({:enum, _}, v) do
        ":string"
      else
        inspect(v)
      end %><%= schema.migration_defaults[k] %>
<% end %><%= for {k, _, _, _} <- schema.assocs do %>
      add <%= inspect k %>, references(:<%= elem(schema.assocs[k], 1) %>, on_delete: :nothing, type: :string)
<% end %>
      timestamps(type: :utc_datetime_usec)
    end

<%= for index <- schema.indexes do %>    <%= index %>
<% end %>
  end
end
