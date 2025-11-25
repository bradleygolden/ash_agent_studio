defmodule AshAgentStudio.Layouts.Root do
  @moduledoc """
  Root layout for Ash Agent Studio LiveViews.
  """
  use Phoenix.Component

  def root(assigns) do
    assigns = assign_new(assigns, :base_path, fn -> "/" end)

    ~H"""
    <!DOCTYPE html>
    <html lang="en" class="dark">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="csrf-token" content={Plug.CSRFProtection.get_csrf_token()} />
        <title>Ash Agent Studio</title>
        <link phx-track-static rel="stylesheet" href={Path.join(@base_path, "assets/app.css")} />
        <script defer phx-track-static src={Path.join(@base_path, "assets/app.js")}></script>
      </head>
      <body class="antialiased">
        <%= @inner_content %>
      </body>
    </html>
    """
  end
end
