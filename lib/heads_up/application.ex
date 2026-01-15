defmodule HeadsUp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
      OpentelemetryBandit.setup()
      OpentelemetryPhoenix.setup(adapter: :bandit)
      OpentelemetryEcto.setup([:heads_up, :repo])

      if Code.ensure_loaded?(OpentelemetryLoggerMetadata) do
         Logger.add_backend(OpentelemetryLoggerMetadata)
      end

      children = [
        HeadsUp.Repo,
        HeadsUpWeb.Endpoint,
        HeadsUpWeb.Telemetry,
        {DNSCluster, query: Application.get_env(:heads_up, :dns_cluster_query) || :ignore},
        {Phoenix.PubSub, name: HeadsUp.PubSub},
        {Finch, name: HeadsUp.Finch},
        {HeadsUp.OtelLogsSender, []},
        HeadsUpWeb.Presence,
      ]

      opts = [strategy: :one_for_one, name: HeadsUp.Supervisor]
      Supervisor.start_link(children, opts)
    end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HeadsUpWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
