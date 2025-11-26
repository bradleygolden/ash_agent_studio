defmodule AshAgentStudio.Layouts do
  use Phoenix.Component

  slot(:inner_block)
  attr(:flash, :map, default: %{})
  attr(:page_title, :string, default: nil)

  attr(:base_path, :string, default: "/")

  attr(:current_page, :atom, default: :observe)

  def app(assigns) do
    ~H"""
    <link phx-track-static rel="stylesheet" href={Path.join(@base_path, "assets/app.css")} />
    <div class="h-screen overflow-hidden flex flex-col bg-slate-50 text-slate-900 dark:bg-[#0B1120] dark:text-slate-100">
      <header class="shrink-0 z-30 border-b border-slate-200 bg-white/80 backdrop-blur-md dark:border-white/5 dark:bg-[#0B1120]/80">
        <div class="mx-auto flex max-w-7xl items-center justify-between px-4 sm:px-6 lg:px-8 h-16">
          <div class="flex items-center gap-6">
            <a href={@base_path} class="flex items-center gap-3">
              <div class="flex h-8 w-8 items-center justify-center rounded-lg bg-indigo-600 text-sm font-bold text-white shadow-sm shadow-indigo-500/20">
                AS
              </div>
              <div class="text-sm font-semibold tracking-tight text-slate-900 dark:text-white">
                Ash Agent Studio
              </div>
            </a>
            <nav class="flex items-center gap-1">
              <a
                href={@base_path}
                class={[
                  "px-3 py-1.5 rounded-md text-sm font-medium transition-colors",
                  if(@current_page == :observe,
                    do: "bg-indigo-100 text-indigo-700 dark:bg-indigo-900/50 dark:text-indigo-300",
                    else:
                      "text-slate-600 hover:text-slate-900 hover:bg-slate-100 dark:text-slate-400 dark:hover:text-white dark:hover:bg-slate-800"
                  )
                ]}
              >
                Observe
              </a>
              <a
                href={Path.join(@base_path, "playground")}
                class={[
                  "px-3 py-1.5 rounded-md text-sm font-medium transition-colors",
                  if(@current_page == :playground,
                    do: "bg-indigo-100 text-indigo-700 dark:bg-indigo-900/50 dark:text-indigo-300",
                    else:
                      "text-slate-600 hover:text-slate-900 hover:bg-slate-100 dark:text-slate-400 dark:hover:text-white dark:hover:bg-slate-800"
                  )
                ]}
              >
                Playground
              </a>
            </nav>
          </div>
        </div>
      </header>

      <main class="flex-1 overflow-y-auto flex flex-col mx-auto w-full max-w-7xl px-4 sm:px-6 lg:px-8 py-8">
        {render_slot(@inner_block)}
      </main>
    </div>
    """
  end
end
