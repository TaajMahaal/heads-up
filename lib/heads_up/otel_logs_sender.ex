defmodule HeadsUp.OtelLogsSender do
  @moduledoc """
  GenServer that captures Logger events and sends them to OpenTelemetry Collector
  """
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    # Attach to telemetry events for logging
    :telemetry.attach_many(
      "otel-logs-handler",
      [
        [:phoenix, :endpoint, :start],
        [:phoenix, :router_dispatch, :stop],
        [:heads_up, :repo, :query]
      ],
      &__MODULE__.handle_event/4,
      nil
    )

    {:ok, %{}}
  end

  def handle_event(event_name, measurements, metadata, _config) do
    timestamp = System.system_time(:nanosecond)

    # Format a readable log message based on event type
    {message, severity} = format_event_message(event_name, measurements, metadata)

    # Extract useful attributes
    attributes = build_attributes(event_name, measurements, metadata)

    send_to_otel(timestamp, message, severity, attributes)
  end

  defp format_event_message([:phoenix, :endpoint, :start], _measurements, metadata) do
    conn = metadata[:conn]
    method = if conn, do: conn.method, else: "GET"
    path = if conn, do: conn.request_path, else: metadata[:route] || "/"
    {"#{method} #{path} - Request started", "INFO"}
  end

  defp format_event_message([:phoenix, :router_dispatch, :stop], measurements, metadata) do
    duration_ms = System.convert_time_unit(measurements[:duration], :native, :millisecond)
    route = metadata[:route] || "unknown"
    {"Request completed: #{route} in #{duration_ms}ms", "INFO"}
  end

  defp format_event_message([:heads_up, :repo, :query], measurements, metadata) do
    duration_ms = System.convert_time_unit(measurements[:total_time], :native, :millisecond)
    query = String.slice(to_string(metadata[:query] || ""), 0, 150)

    # Extract result info
    result_info = case metadata[:result] do
      {:ok, %{rows: rows, command: command}} when is_list(rows) ->
        " [#{command}, #{length(rows)} rows]"
      {:ok, %{command: command}} ->
        " [#{command}]"
      _ ->
        ""
    end

    {"DB Query#{result_info} (#{duration_ms}ms): #{query}", "DEBUG"}
  end

  defp format_event_message(event_name, _measurements, _metadata) do
    {"Event: #{inspect(event_name)}", "INFO"}
  end

  defp build_attributes(event_name, measurements, metadata) do
    base_attributes = [
      %{key: "service.name", value: %{stringValue: "heads_up"}},
      %{key: "event.name", value: %{stringValue: Enum.join(event_name, ".")}}
    ]

    # Add all measurements as attributes
    measurement_attrs = measurements
    |> Enum.flat_map(fn {key, value} ->
      case key do
        k when k in [:duration, :total_time, :decode_time, :query_time, :queue_time, :idle_time] ->
          ms = System.convert_time_unit(value, :native, :millisecond)
          [%{key: "#{key}_ms", value: %{intValue: ms}}]
        _ when is_number(value) ->
          [%{key: to_string(key), value: %{intValue: value}}]
        _ ->
          []
      end
    end)

    # Add route if available
    route_attrs = if metadata[:route] do
      [%{key: "route", value: %{stringValue: to_string(metadata[:route])}}]
    else
      []
    end

    # Add HTTP method if available
    method_attrs = case metadata[:conn] do
      %Plug.Conn{method: method} when is_binary(method) ->
        [%{key: "http.method", value: %{stringValue: method}}]
      _ ->
        []
    end

    # Add database query details
    db_attrs = case event_name do
      [:heads_up, :repo, :query] ->
        query_attrs = [
          %{key: "db.system", value: %{stringValue: "postgresql"}},
          %{key: "db.query", value: %{stringValue: to_string(metadata[:query] || "")}}
        ]

        # Add result details
        result_attrs = case metadata[:result] do
          {:ok, %{command: command, rows: rows, columns: columns}} when is_list(rows) and is_list(columns) ->
            [
              %{key: "db.command", value: %{stringValue: to_string(command)}},
              %{key: "db.rows_count", value: %{intValue: length(rows)}},
              %{key: "db.columns", value: %{stringValue: Enum.join(columns, ", ")}}
            ]
          {:ok, %{command: command}} ->
            [%{key: "db.command", value: %{stringValue: to_string(command)}}]
          _ ->
            []
        end

        # Add stacktrace (top 3 entries for context)
        stack_attrs = if metadata[:stacktrace] do
          stack_str = metadata[:stacktrace]
          |> Enum.take(3)
          |> Enum.map(fn {mod, fun, arity, location} ->
            file = location[:file] || ""
            line = location[:line] || 0
            "#{mod}.#{fun}/#{arity} (#{file}:#{line})"
          end)
          |> Enum.join(" -> ")

          [%{key: "stacktrace", value: %{stringValue: stack_str}}]
        else
          []
        end

        query_attrs ++ result_attrs ++ stack_attrs

      _ ->
        []
    end

    base_attributes ++ measurement_attrs ++ route_attrs ++ method_attrs ++ db_attrs
  end

  defp send_to_otel(timestamp, message, severity, attributes) do
    # Get current trace context
    span_ctx = :otel_tracer.current_span_ctx()

    # Add trace_id and span_id if available
    {enhanced_message, log_record_updates} = if :otel_span.is_recording(span_ctx) do
      trace_id = :otel_span.trace_id(span_ctx)
      span_id = :otel_span.span_id(span_ctx)

      trace_id_hex = Base.encode16(<<trace_id::128>>, case: :lower)
      span_id_hex = Base.encode16(<<span_id::64>>, case: :lower)

      # Include trace_id in the message for derived field extraction
      enhanced_msg = "#{message} trace_id=#{trace_id_hex}"

      updates = %{
        traceId: trace_id_hex,
        spanId: span_id_hex
      }

      {enhanced_msg, updates}
    else
      {message, %{}}
    end

    # Build log record with trace context
    log_record = %{
      timeUnixNano: to_string(timestamp),
      severityText: severity,
      body: %{stringValue: enhanced_message}
    }
    |> Map.merge(log_record_updates)

    body = %{
      resourceLogs: [
        %{
          resource: %{
            attributes: attributes
          },
          scopeLogs: [
            %{
              logRecords: [log_record]
            }
          ]
        }
      ]
    }

    # Send to OTEL Collector
    case Finch.build(:post, "http://localhost:4318/v1/logs", [{"content-type", "application/json"}], Jason.encode!(body))
         |> Finch.request(HeadsUp.Finch) do
      {:ok, _response} -> :ok
      {:error, reason} -> Logger.debug("Failed to send logs to OTEL: #{inspect(reason)}")
    end
  end
end
