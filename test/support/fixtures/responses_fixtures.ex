defmodule HeadsUp.ResponsesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HeadsUp.Responses` context.
  """

  @doc """
  Generate a response.
  """
  def response_fixture(attrs \\ %{}) do
    {:ok, response} =
      attrs
      |> Enum.into(%{
        note: "some note",
        status: :enroute
      })
      |> HeadsUp.Responses.create_response()

    response
  end

  @doc """
  Generate a response.
  """
  def response_fixture(attrs \\ %{}) do
    {:ok, response} =
      attrs
      |> Enum.into(%{
        incident_id: "some incident_id",
        note: "some note",
        status: :enroute,
        user_id: "7488a646-e31f-11e4-aace-600308960662"
      })
      |> HeadsUp.Responses.create_response()

    response
  end
end
