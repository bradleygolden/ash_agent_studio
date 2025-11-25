defmodule AshAgentStudio.PlaygroundLive do
  @moduledoc """
  Interactive playground for testing Ash agents.

  Allows users to select an agent, fill in inputs, and run the agent
  with real-time streaming output.
  """

  use Phoenix.LiveView

  alias AshAgentStudio.Layouts
  alias AshAgentStudio.Registry

  @impl true
  def mount(_params, session, socket) do
    base_path = session["ash_agent_studio_base_path"] || ""
    agents = Registry.list_agents()

    {:ok,
     assign(socket,
       base_path: base_path,
       agents: agents,
       selected_agent: nil,
       agent_config: nil,
       input_args: [],
       form: to_form(%{}, as: :input),
       running?: false,
       output: nil,
       error: nil,
       stream_chunks: []
     )}
  end

  @impl true
  def handle_event("select_agent", %{"agent" => module_string}, socket) do
    if module_string == "" do
      {:noreply,
       assign(socket,
         selected_agent: nil,
         agent_config: nil,
         input_args: [],
         form: to_form(%{}, as: :input),
         output: nil,
         error: nil
       )}
    else
      module = String.to_existing_atom(module_string)
      {:ok, studio_config} = Registry.get_config(module)

      # Try to get agent input args if AshAgent.Info is available
      input_args = get_agent_input_args(module)

      {:noreply,
       assign(socket,
         selected_agent: module,
         agent_config: studio_config,
         input_args: input_args,
         form: to_form(default_values(input_args), as: :input),
         output: nil,
         error: nil
       )}
    end
  end

  def handle_event("run_agent", %{"input" => params}, socket) do
    module = socket.assigns.selected_agent

    if module && not socket.assigns.running? do
      # Convert params to keyword list with proper types
      args = build_args(params, socket.assigns.input_args)

      # Start async task to run the agent
      socket = assign(socket, running?: true, output: nil, error: nil, stream_chunks: [])

      task =
        Task.async(fn ->
          run_agent(module, args)
        end)

      {:noreply, assign(socket, task: task)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("validate", %{"input" => params}, socket) do
    {:noreply, assign(socket, form: to_form(params, as: :input))}
  end

  @impl true
  def handle_info({ref, result}, socket) do
    if socket.assigns[:task] && socket.assigns.task.ref == ref do
      Process.demonitor(ref, [:flush])

      case result do
        {:ok, output} ->
          {:noreply, assign(socket, running?: false, output: output, error: nil, task: nil)}

        {:error, error} ->
          {:noreply,
           assign(socket, running?: false, output: nil, error: inspect(error), task: nil)}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, reason}, socket) do
    if socket.assigns[:task] && socket.assigns.task.ref == ref do
      {:noreply,
       assign(socket, running?: false, error: "Agent crashed: #{inspect(reason)}", task: nil)}
    else
      {:noreply, socket}
    end
  end

  def handle_info(_msg, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} base_path={@base_path} current_page={:playground}>
      <div class="max-w-4xl mx-auto p-6">
        <div class="mb-8">
          <h1 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">Playground</h1>
          <p class="text-gray-600 dark:text-gray-400">
            Test your agents interactively
          </p>
        </div>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Left: Agent Selection & Input -->
        <div class="space-y-6">
          <!-- Agent Selector -->
          <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Select Agent
            </label>
            <select
              phx-change="select_agent"
              name="agent"
              class="w-full rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
            >
              <option value="">Choose an agent...</option>
              <%= for {module, config} <- @agents do %>
                <option value={module} selected={@selected_agent == module}>
                  <%= config.label %>
                </option>
              <% end %>
            </select>

            <%= if @agent_config && @agent_config.description do %>
              <p class="mt-2 text-sm text-gray-500 dark:text-gray-400">
                <%= @agent_config.description %>
              </p>
            <% end %>
          </div>

          <!-- Input Form -->
          <%= if @selected_agent do %>
            <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
              <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Inputs</h3>

              <.form for={@form} phx-submit="run_agent" phx-change="validate" class="space-y-4">
                <%= if @input_args == [] do %>
                  <p class="text-sm text-gray-500 dark:text-gray-400 italic">
                    No input arguments defined for this agent.
                  </p>
                <% else %>
                  <%= for arg <- @input_args do %>
                    <div>
                      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                        <%= humanize_name(arg.name) %>
                        <%= unless arg.allow_nil? do %>
                          <span class="text-red-500">*</span>
                        <% end %>
                      </label>
                      <%= render_input(arg, @form) %>
                      <%= if arg.doc do %>
                        <p class="mt-1 text-xs text-gray-500 dark:text-gray-400">
                          <%= arg.doc %>
                        </p>
                      <% end %>
                    </div>
                  <% end %>
                <% end %>

                <button
                  type="submit"
                  disabled={@running?}
                  class={[
                    "w-full py-2 px-4 rounded-md text-white font-medium",
                    "focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500",
                    if(@running?,
                      do: "bg-gray-400 cursor-not-allowed",
                      else: "bg-indigo-600 hover:bg-indigo-700"
                    )
                  ]}
                >
                  <%= if @running? do %>
                    <span class="flex items-center justify-center">
                      <svg
                        class="animate-spin -ml-1 mr-2 h-4 w-4 text-white"
                        fill="none"
                        viewBox="0 0 24 24"
                      >
                        <circle
                          class="opacity-25"
                          cx="12"
                          cy="12"
                          r="10"
                          stroke="currentColor"
                          stroke-width="4"
                        >
                        </circle>
                        <path
                          class="opacity-75"
                          fill="currentColor"
                          d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                        >
                        </path>
                      </svg>
                      Running...
                    </span>
                  <% else %>
                    Run Agent
                  <% end %>
                </button>
              </.form>
            </div>
          <% end %>
        </div>

        <!-- Right: Output -->
        <div class="space-y-6">
          <%= if @selected_agent do %>
            <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
              <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Output</h3>

              <%= cond do %>
                <% @error -> %>
                  <div class="p-4 bg-red-50 dark:bg-red-900/20 rounded-lg">
                    <p class="text-sm text-red-700 dark:text-red-400 font-mono whitespace-pre-wrap">
                      <%= @error %>
                    </p>
                  </div>
                <% @output -> %>
                  <div class="p-4 bg-gray-50 dark:bg-gray-900 rounded-lg">
                    <pre class="text-sm text-gray-800 dark:text-gray-200 whitespace-pre-wrap font-mono overflow-auto max-h-96"><%= format_output(@output) %></pre>
                  </div>
                <% @running? -> %>
                  <div class="flex items-center justify-center py-12 text-gray-500 dark:text-gray-400">
                    <svg
                      class="animate-spin h-8 w-8 mr-3"
                      fill="none"
                      viewBox="0 0 24 24"
                    >
                      <circle
                        class="opacity-25"
                        cx="12"
                        cy="12"
                        r="10"
                        stroke="currentColor"
                        stroke-width="4"
                      >
                      </circle>
                      <path
                        class="opacity-75"
                        fill="currentColor"
                        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                      >
                      </path>
                    </svg>
                    Processing...
                  </div>
                <% true -> %>
                  <p class="text-sm text-gray-500 dark:text-gray-400 italic text-center py-12">
                    Run the agent to see output here
                  </p>
              <% end %>
            </div>
          <% else %>
            <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
              <p class="text-sm text-gray-500 dark:text-gray-400 italic text-center py-12">
                Select an agent to get started
              </p>
            </div>
          <% end %>
        </div>
      </div>
      </div>
    </Layouts.app>
    """
  end

  # Helper functions

  defp get_agent_input_args(module) do
    # Try to use AshAgent.Info if available
    if Code.ensure_loaded?(AshAgent.Info) do
      try do
        apply(AshAgent.Info, :input_args, [module])
      rescue
        _ -> []
      end
    else
      []
    end
  end

  defp default_values(input_args) do
    input_args
    |> Enum.map(fn arg ->
      {to_string(arg.name), arg[:default] || ""}
    end)
    |> Map.new()
  end

  defp build_args(params, input_args) do
    input_args
    |> Enum.map(fn arg ->
      value = Map.get(params, to_string(arg.name), "")
      {arg.name, coerce_value(value, arg.type)}
    end)
  end

  defp coerce_value("", _type), do: nil
  defp coerce_value(value, :string), do: value
  defp coerce_value(value, :integer), do: String.to_integer(value)
  defp coerce_value(value, :float), do: String.to_float(value)
  defp coerce_value("true", :boolean), do: true
  defp coerce_value("false", :boolean), do: false
  defp coerce_value(value, :boolean), do: value in ["true", "1", "yes"]
  defp coerce_value(value, :map), do: Jason.decode!(value)
  defp coerce_value(value, :list), do: Jason.decode!(value)
  defp coerce_value(value, _), do: value

  defp run_agent(module, args) do
    # Try to call the agent using Ash actions
    if function_exported?(module, :call, 1) do
      module.call(args)
    else
      {:error, "Agent does not export call/1 function"}
    end
  rescue
    e -> {:error, e}
  end

  defp render_input(arg, form) do
    assigns = %{form: form, arg: arg, name: to_string(arg.name)}

    case arg.type do
      :boolean ->
        ~H"""
        <input
          type="checkbox"
          name={"input[#{@name}]"}
          value="true"
          checked={@form[@name].value == "true"}
          class="rounded border-gray-300 dark:border-gray-600 text-indigo-600 focus:ring-indigo-500"
        />
        """

      :integer ->
        ~H"""
        <input
          type="number"
          name={"input[#{@name}]"}
          value={@form[@name].value}
          class="w-full rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
        />
        """

      :float ->
        ~H"""
        <input
          type="number"
          step="0.01"
          name={"input[#{@name}]"}
          value={@form[@name].value}
          class="w-full rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
        />
        """

      type when type in [:map, :list] ->
        placeholder = if(type == :map, do: "{}", else: "[]")
        assigns = Map.put(assigns, :placeholder, placeholder)

        ~H"""
        <textarea
          name={"input[#{@name}]"}
          rows="4"
          placeholder={@placeholder}
          class="w-full rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white shadow-sm focus:border-indigo-500 focus:ring-indigo-500 font-mono text-sm"
        ><%= @form[@name].value %></textarea>
        """

      _ ->
        ~H"""
        <textarea
          name={"input[#{@name}]"}
          rows="3"
          class="w-full rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
        ><%= @form[@name].value %></textarea>
        """
    end
  end

  defp humanize_name(name) do
    name
    |> to_string()
    |> String.replace("_", " ")
    |> String.split()
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp format_output(output) when is_struct(output) do
    output
    |> Map.from_struct()
    |> Jason.encode!(pretty: true)
  end

  defp format_output(output) when is_map(output) do
    Jason.encode!(output, pretty: true)
  end

  defp format_output(output) when is_binary(output), do: output
  defp format_output(output), do: inspect(output, pretty: true)
end
