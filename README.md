# Ash Agent Studio

A comprehensive Phoenix LiveView platform for developing, testing, and monitoring Ash agents.

Think of it like LangSmith for Ash agents—an all-in-one studio for observability, interactive testing, and prompt management. The package embeds into existing Phoenix applications via a router macro, similar to `Phoenix.LiveDashboard`.

## Features

- **Observe** - Real-time monitoring of agent runs with event timelines
- **Playground** - Interactive agent testing with dynamic input forms (coming soon)
- **Prompt Visibility** - View rendered prompts for each run (coming soon)
- **Optional Persistence** - In-memory by default, with optional Ecto persistence

## Installation

Add the dependency:

```elixir
def deps do
  [
    {:ash_agent_studio, path: "../ash_agent_studio"}
  ]
end
```

Fetch deps with `mix deps.get`.

## Mounting the Studio

Mount the provided router macro anywhere inside your application's router:

```elixir
defmodule MyAppWeb.Router do
  use MyAppWeb, :router
  use AshAgentStudio.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
  end

  scope "/" do
    pipe_through [:browser, :require_authenticated_user]
    ash_agent_studio "/studio"
  end
end
```

- `ash_agent_studio/2` expects the mount path as the first argument.
- Pass `:as` to customize the helper prefix (`:ash_agent_studio` by default).

## Development

Useful tasks:

- `mix deps.get` – install dependencies
- `mix test` – run the library test suite
- `mix format` – format Elixir and HEEx files

No asset compilation or Phoenix endpoint exists in this project—the host application provides HTTP, authentication, and static assets.
