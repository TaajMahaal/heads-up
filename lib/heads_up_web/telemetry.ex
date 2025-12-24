defmodule HeadsUpWeb.Telemetry do
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      # Telemetry poller will execute the given period measurements
      # every 10_000ms. Learn more here: https://hexdocs.pm/telemetry_metrics
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000},
      # Prometheus metrics exporter on /metrics endpoint
      {TelemetryMetricsPrometheus.Core, metrics: metrics(), port: 9568}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      # Phoenix Metrics - HTTP Request Duration
      distribution("phoenix.endpoint.stop.duration",
        unit: {:native, :millisecond},
        description: "HTTP request duration",
        reporter_options: [buckets: [10, 50, 100, 200, 500, 1000, 2000, 5000]]
      ),
      distribution("phoenix.router_dispatch.stop.duration",
        tags: [:route],
        unit: {:native, :millisecond},
        description: "Router dispatch duration",
        reporter_options: [buckets: [10, 50, 100, 200, 500, 1000, 2000, 5000]]
      ),
      distribution("phoenix.router_dispatch.exception.duration",
        tags: [:route],
        unit: {:native, :millisecond},
        description: "Router exception duration",
        reporter_options: [buckets: [10, 50, 100, 200, 500, 1000]]
      ),
      distribution("phoenix.socket_connected.duration",
        unit: {:native, :millisecond},
        description: "WebSocket connection duration",
        reporter_options: [buckets: [10, 50, 100, 200, 500, 1000]]
      ),
      counter("phoenix.socket_drain.count",
        description: "WebSocket drain count"
      ),
      distribution("phoenix.channel_joined.duration",
        unit: {:native, :millisecond},
        description: "Channel join duration",
        reporter_options: [buckets: [10, 50, 100, 200, 500, 1000]]
      ),
      distribution("phoenix.channel_handled_in.duration",
        tags: [:event],
        unit: {:native, :millisecond},
        description: "Channel message handling duration",
        reporter_options: [buckets: [10, 50, 100, 200, 500, 1000]]
      ),

      # Database Metrics
      distribution("heads_up.repo.query.total_time",
        unit: {:native, :millisecond},
        description: "Total database query time",
        reporter_options: [buckets: [1, 5, 10, 25, 50, 100, 250, 500, 1000]]
      ),
      distribution("heads_up.repo.query.decode_time",
        unit: {:native, :millisecond},
        description: "Time spent decoding database results",
        reporter_options: [buckets: [1, 5, 10, 25, 50, 100]]
      ),
      distribution("heads_up.repo.query.query_time",
        unit: {:native, :millisecond},
        description: "Time spent executing the query",
        reporter_options: [buckets: [1, 5, 10, 25, 50, 100, 250, 500, 1000]]
      ),
      distribution("heads_up.repo.query.queue_time",
        unit: {:native, :millisecond},
        description: "Time spent waiting for a database connection",
        reporter_options: [buckets: [1, 5, 10, 25, 50, 100, 250]]
      ),
      distribution("heads_up.repo.query.idle_time",
        unit: {:native, :millisecond},
        description: "Time the connection spent idle before being checked out",
        reporter_options: [buckets: [1, 5, 10, 25, 50, 100]]
      ),

      # VM Metrics - Use last_value for gauges
      last_value("vm.memory.total",
        unit: {:byte, :kilobyte},
        description: "Total VM memory"
      ),
      last_value("vm.total_run_queue_lengths.total",
        description: "Total run queue length"
      ),
      last_value("vm.total_run_queue_lengths.cpu",
        description: "CPU run queue length"
      ),
      last_value("vm.total_run_queue_lengths.io",
        description: "IO run queue length"
      )
    ]
  end

  defp periodic_measurements do
    [
      # A module, function and arguments to be invoked periodically.
      # This function must call :telemetry.execute/3 and a metric must be added above.
      # {HeadsUpWeb, :count_users, []}
    ]
  end
end
