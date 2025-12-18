defmodule HeadsUp.Incidents do
  def list_incidents do
  end

  def get_incident(id) when is_integer(id) do
    list_incidents() |> Enum.find(fn f -> f.id == id end)
  end

  def get_incident(id) when is_binary(id) do
    id |> String.to_integer() |> get_incident()
  end

  def urgent_incidents(incident) do
    list_incidents() |> Enum.reject(fn i -> i.id === incident.id end)
  end
end
