# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Communication Style

- Use "tu" (tutoiement) when addressing the user with an unformal tone
- Avoid praise phrases
- Keep tone direct and informative without unnecessary enthusiasm, but keep the tone enthusiasmic enough to not be cold as fuck
- Focus on technical substance over encouragement

## Project Overview

HeadsUp is a **learning project** for exploring the Elixir/Phoenix/Ecto stack. It's an incident tracking application built with Phoenix 1.7 LiveView that demonstrates:
- Context-driven domain modeling (Incidents, Categories, Admin)
- Phoenix LiveView for real-time UI
- Custom Ecto types (prefixed ULIDs)
- OpenTelemetry monitoring integration
- Modern Phoenix patterns and conventions
- PubSub mechanmisms
- Presence

## Development Commands

### Initial Setup
```bash
mix setup  # Install deps, setup DB, install and build assets
```

### Running the Application
```bash
mix phx.server                 # Start server
iex -S mix phx.server         # Start server with IEx console
```
The app runs at http://localhost:4000

### Database Operations
```bash
mix ecto.create               # Create database
mix ecto.migrate              # Run migrations
mix ecto.rollback             # Rollback last migration
mix ecto.reset                # Drop, create, migrate, and seed
mix run priv/repo/seeds.exs   # Run seeds
```

### Testing
```bash
mix test                      # Run all tests (auto-creates/migrates test DB)
mix test test/path/to/test.exs:LINE_NUMBER  # Run specific test
```

### Code Quality
```bash
mix format                    # Format code
mix dialyzer                  # Run static analysis (PLT files in priv/plts/)
```

### Assets
```bash
mix assets.setup              # Install Tailwind and esbuild
mix assets.build              # Build assets for development
mix assets.deploy             # Build and minify for production
```

## Architecture

### Domain Contexts

The application follows Phoenix context patterns to organize domain logic:

**HeadsUp.Incidents** (`lib/heads_up/incidents.ex`) - Public-facing incident queries
- Demonstrates composable query building with private helper functions
- `filter_incidents/1` - Combines multiple filters (status, search, sort)
- `urgent_incidents/1` - Shows prioritization logic
- Query helpers like `with_status/2`, `search_by/2`, `sort/2` handle nil/empty gracefully

**HeadsUp.Admin** (`lib/heads_up/admin.ex`) - Administrative operations
- Full CRUD for incidents
- Separated from public context to demonstrate access boundaries
- Shows pattern of having multiple contexts for same schema with different permissions

**HeadsUp.Categories** (`lib/heads_up/categories.ex`) - Standard CRUD context
- Generated Phoenix context demonstrating conventional CRUD operations
- Good reference for standard context patterns

### Custom ID System - Prefixed ULIDs

A learning example of custom Ecto types. All schemas use prefixed ULIDs instead of auto-increment integers:

**Implementation:** `lib/heads_up/ecto/prefixed_id.ex`
- Format: `{prefix}_{26-char-ulid}` (e.g., `icd_01ARZ3NDEKTSV4RRFFQ69G5FAV`)
- Globally unique, sortable by creation time
- Type-identifiable (prefix indicates entity type)
- Uses `Ecto.ParameterizedType` behavior

**Schema Macro:** `lib/heads_up/schema.ex`
- Configures `@primary_key` and `@foreign_key_type` automatically
- Schemas use this via: `use HeadsUp.Schema, prefix: "xyz"`
- Current prefixes: `icd` (incidents), `ctg` (categories)

**Key implications:**
- Primary keys and foreign keys are `:string` type, not `:integer`
- Must use `Repo.preload/2` for associations (no integer-based optimizations)
- Pattern matching on IDs can identify entity type from prefix

### Web Layer Structure

**HeadsUpWeb Module** (`lib/heads_up_web.ex`)
- Provides `__using__` macros that inject common functionality
- `:live_view` - For LiveView pages
- `:live_component` - For stateful components
- `:html` - For function components
- `:controller` - For traditional controllers

**Component Organization:**
- `core_components.ex` - Phoenix-generated core UI components
- `custom_components.ex` - App-specific reusable components
- `incident_components.ex` - Domain-specific incident components
- `layouts.ex` - Root and app layouts

**LiveView Pages:**
- `incident_live/` - Public browsing (demonstrating read-only LiveView patterns)
- `admin_incident_live/` - Admin CRUD (demonstrating forms and updates)
- `category_live/` - Full CRUD example
- `effort_live/` - Additional LiveView exploration

### Router Patterns

**Public Routes** (`/`):
- Landing and browsing pages
- Pattern: separate public vs admin functionality

**Admin Routes** (`/admin`):
- Administrative operations
- Demonstrates route organization by permission level

**Dev Routes** (`/dev`):
- Only available in development (`if Application.compile_env(:heads_up, :dev_routes)`)
- LiveDashboard for telemetry
- Swoosh mailbox preview

### OpenTelemetry Integration

Demonstrates comprehensive monitoring setup for learning observability:

**Instrumentation** (`lib/heads_up/application.ex`):
- `OpentelemetryPhoenix.setup(adapter: :bandit)` - HTTP instrumentation
- `OpentelemetryEcto.setup([:heads_up, :repo])` - Database query tracking
- `OpentelemetryBandit.setup()` - Bandit web server instrumentation
- Custom `HeadsUp.OtelLogsSender` - Log export pipeline

**Local Monitoring Stack** (`monitoring/`):
- Docker Compose with Grafana, Prometheus, Tempo
- Pre-configured dashboards
- Run: `docker compose -f monitoring/docker-compose.yaml up`

### Database & Ecto Patterns

**Query Composition Pattern:**
This codebase demonstrates building queries with composable helper functions:

```elixir
def filter_incidents(filter) do
  Incident
  |> with_status(filter["status"])
  |> search_by(filter["q"])
  |> sort(filter["sort_by"])
  |> Repo.all()
end

defp with_status(query, status) when status in ~w"pending resolved" do
  where(query, status: ^status)
end
defp with_status(query, _), do: query  # Handle nil/invalid gracefully
```

**Schema Conventions:**
- All schemas use `HeadsUp.Schema` macro for consistent configuration
- Timestamps: `:utc_datetime_usec` for microsecond precision
- Enums: `Ecto.Enum` for type-safe status fields
- Validations in changeset functions

**Association Loading:**
- Must explicitly preload associations
- Use `Repo.preload(:association)` or query `preload/2`
- Example in `incidents.ex:9`: `Repo.get!(Incident, id) |> Repo.preload(:category)`

## Key Learning Examples

### LiveView Patterns
The app demonstrates several LiveView patterns:
- Real-time updates without page refreshes
- Form handling with changesets
- Component composition
- Using `~p` sigil for verified routes

### Phoenix Contexts
Shows different context patterns:
- Public read-heavy context (Incidents)
- Admin write-heavy context (Admin)
- Standard generated CRUD (Categories)
- How multiple contexts can work with the same schema

### Custom Ecto Types
The prefixed ULID implementation demonstrates:
- Implementing `Ecto.ParameterizedType` behavior
- Custom autogeneration logic
- Validation during casting
- Integration with Phoenix forms

### Testing Structure
- Tests auto-setup database with `Ecto.Adapters.SQL.Sandbox`
- Generated test examples for LiveView and contexts
- Pattern: test both successful and error cases

## Configuration Files

- `config/config.exs` - Base app configuration, imports environment configs
- `config/dev.exs` - Development: live reload, debugging
- `config/test.exs` - Test: SQL sandbox, async tests
- `config/runtime.exs` - Production: environment variables, secrets
- `config/prod.exs` - Production: release settings

## Asset Pipeline

- Tailwind CSS via Mix task (config: `assets/tailwind.config.js`)
- esbuild for JavaScript (config: `assets/js/`)
- Heroicons available for UI icons
- Static files: `priv/static/`
