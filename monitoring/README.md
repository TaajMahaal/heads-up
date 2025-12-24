# HeadsUp Observability Stack

Full observability stack with metrics, logs, and traces for Phoenix/Elixir applications.

## Stack Components

- **VictoriaMetrics**: Time-series database for metrics (Prometheus-compatible)
- **VictoriaLogs**: Log aggregation and querying
- **Tempo**: Distributed tracing backend
- **Grafana**: Visualization and dashboards
- **OpenTelemetry Collector**: Telemetry data collection and processing
- **PostgreSQL**: Application database

## Quick Start

### 1. Start the monitoring stack

```bash
cd monitoring
docker compose up -d
```

This will start all services:
- Grafana: http://localhost:3000 (admin/admin)
- VictoriaMetrics: http://localhost:8428
- VictoriaLogs: http://localhost:9428
- Tempo: http://localhost:3200
- OTEL Collector: http://localhost:4318 (HTTP), 4317 (gRPC)
- PostgreSQL: localhost:5433

### 2. Install Phoenix dependencies

```bash
cd ..
mix deps.get
```

### 3. Setup database

```bash
mix ecto.setup
```

### 4. Start the Phoenix application

```bash
mix phx.server
```

The application will be available at http://localhost:4000

### 5. Access Grafana

1. Open http://localhost:3000
2. Login with `admin`/`admin` (change password if prompted)
3. Navigate to Dashboards → "HeadsUp Observability"

## What You'll See

The pre-configured dashboard includes:

### Metrics
- **HTTP Request Rate**: Requests per second
- **HTTP Response Times**: p50, p95, p99 percentiles
- **Database Query Times**: Query duration percentiles
- **Database Query Rate**: Queries per second
- **BEAM VM Memory**: Erlang VM memory usage
- **Run Queue Length**: BEAM scheduler queue depth

### Logs
- **Application Logs Stream**: Real-time logs from the application
- Filterable by severity, component, and other fields
- **Logs ↔ Traces linking**: Click trace_id in logs to view the trace

### Traces
- **Recent Traces**: Latest distributed traces
- **Trace Details**: Span timing, relationships, and context
- **Traces ↔ Logs linking**: Click "Logs" button in a trace to view related logs

## How It Works

### Application Instrumentation

The Phoenix app is instrumented with:

1. **OpenTelemetry**: Auto-instrumentation for Phoenix, Ecto, and Bandit
   - Configured in `config/config.exs`
   - Sends traces to OTEL Collector at `localhost:4318`

2. **TelemetryMetricsPrometheus**: Exports Prometheus metrics
   - Configured in `lib/heads_up_web/telemetry.ex`
   - Exposes metrics at `localhost:9568/metrics`

3. **OtelLogsSender**: Custom GenServer that captures telemetry events and sends them as structured logs
   - Located in `lib/heads_up/otel_logs_sender.ex`
   - Adds trace_id to logs for correlation
   - Sends logs to OTEL Collector

### Data Flow

```
Phoenix App
├── Metrics (port 9568) → OTEL Collector → VictoriaMetrics
├── Logs (port 4318) → OTEL Collector → VictoriaLogs
└── Traces (port 4318) → OTEL Collector → Tempo
                                              ↓
                                          Grafana
```

### Logs ↔ Traces Linking

The system automatically correlates logs and traces:

- **Logs → Traces**: Logs include `trace_id` in the message. Grafana's derived fields feature creates clickable links to view the trace in Tempo
- **Traces → Logs**: Click "Logs" in a trace view to see all logs with matching `trace_id`

## Configuration Files

- `docker-compose.yaml`: All infrastructure services
- `otel-collector-config.yaml`: OTEL Collector pipelines
- `grafana-datasources.yaml`: Grafana datasources with linking configured
- `grafana-dashboards.yaml`: Dashboard provisioning config
- `dashboards/heads-up-observability.json`: Pre-built dashboard

## Database Configuration

The Phoenix app is configured to connect to PostgreSQL at `localhost:5433` (see `config/dev.exs`). This matches the port mapping in the Docker Compose file.

If you want to use a different database:
1. Update `config/dev.exs` with your database credentials
2. Remove or comment out the `postgres` service in `docker-compose.yaml`

## Customization

### Change Service Name

Update the service name in two places:
1. `config/config.exs`: `config :opentelemetry, resource: [service: [name: "your-service-name"]]`
2. `lib/heads_up/otel_logs_sender.ex`: Line 77, change `"heads_up"` to your service name
3. Dashboard queries: Update `service.name="heads_up"` in the dashboard JSON

### Add Custom Metrics

Add metrics in `lib/heads_up_web/telemetry.ex`:

```elixir
defp metrics do
  [
    # ... existing metrics ...

    # Your custom metric
    counter("my_app.custom.counter"),
    last_value("my_app.custom.gauge")
  ]
end
```

Then emit the metric in your code:

```elixir
:telemetry.execute([:my_app, :custom, :counter], %{count: 1}, %{})
```

### Add Custom Logs

Logs are automatically captured from telemetry events. To add custom log events:

1. Add the event to the attach list in `lib/heads_up/otel_logs_sender.ex`
2. Add a handler in `format_event_message/3` and `build_attributes/3`

## Troubleshooting

### No metrics in Grafana

1. Check that the Phoenix app is running: `lsof -i :9568`
2. Verify metrics endpoint: `curl http://localhost:9568/metrics`
3. Check OTEL Collector logs: `docker logs monitoring-otel-collector-1`

### No logs in VictoriaLogs

1. Check OTEL Collector logs: `docker logs monitoring-otel-collector-1`
2. Verify logs are being sent: Check `HeadsUp.OtelLogsSender` is started in `application.ex`
3. Test VictoriaLogs directly: `curl http://localhost:9428/select/logsql/query -d 'query=*'`

### No traces in Tempo

1. Verify OpenTelemetry configuration in `config/config.exs`
2. Check OTEL Collector is receiving traces: `docker logs monitoring-otel-collector-1`
3. Test Tempo API: `curl http://localhost:3200/api/search`

### Logs ↔ Traces linking not working

1. Verify trace_id appears in logs: Check VictoriaLogs for logs with trace_id field
2. Check Grafana datasource configuration: `monitoring/grafana-datasources.yaml`
3. Restart Grafana: `docker restart monitoring-grafana-1`

## Stopping the Stack

```bash
cd monitoring
docker compose down
```

To remove volumes (database data):

```bash
docker compose down -v
```

## Production Considerations

This setup is designed for local development. For production:

1. **Secure Grafana**: Change default credentials, enable HTTPS
2. **Scale components**: Add replicas for OTEL Collector, VictoriaMetrics, etc.
3. **Persistent storage**: Configure proper volume mounts and backup strategies
4. **Resource limits**: Add CPU/memory limits to Docker Compose services
5. **Authentication**: Add auth to VictoriaMetrics, VictoriaLogs, Tempo
6. **Retention policies**: Configure data retention for metrics, logs, and traces
7. **OTEL Collector endpoint**: Update Phoenix config to point to production endpoint

## References

- [OpenTelemetry Elixir](https://github.com/open-telemetry/opentelemetry-erlang)
- [VictoriaMetrics](https://docs.victoriametrics.com/)
- [VictoriaLogs](https://docs.victoriametrics.com/victorialogs/)
- [Grafana Tempo](https://grafana.com/docs/tempo/latest/)
- [Phoenix Telemetry](https://hexdocs.pm/phoenix/telemetry.html)
