defmodule AshAgentStudio.MixProject do
  use Mix.Project

  def project do
    [
      app: :ash_agent_studio,
      version: "0.1.0",
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: dialyzer(),
      listeners: [Phoenix.CodeReloader]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {AshAgentStudio.Application, []},
      extra_applications: [:logger]
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:dev), do: ["lib", "dev"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.8.1"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_view, "~> 1.1.0"},
      {:spark, "~> 2.0"},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.2.0",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:jason, "~> 1.2"},
      {:bandit, "~> 1.0"},
      {:igniter, "~> 0.3"},
      {:esbuild, "~> 0.8", only: :dev},
      {:tailwind, "~> 0.2", only: :dev},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.13", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.30", only: [:dev, :test], runtime: false}
    ] ++ sibling_deps()
  end

  defp sibling_deps do
    if in_umbrella?() do
      [
        {:ash_agent, in_umbrella: true},
        {:ash_baml, in_umbrella: true}
      ]
    else
      [
        {:ash, "~> 3.0", only: :dev},
        {:ash_agent, "~> 0.3", only: :dev}
      ]
    end
  end

  defp in_umbrella? do
    # FORCE_HEX_DEPS=true bypasses umbrella detection for hex.publish
    if System.get_env("FORCE_HEX_DEPS") == "true" do
      false
    else
      parent_mix = Path.expand("../../mix.exs", __DIR__)

      File.exists?(parent_mix) and
        parent_mix |> File.read!() |> String.contains?("apps_path")
    end
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      dev: "run --no-halt",
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind ash_agent_studio", "esbuild ash_agent_studio"],
      "assets.deploy": [
        "tailwind ash_agent_studio --minify",
        "esbuild ash_agent_studio --minify",
        "phx.digest"
      ],
      precommit: [
        "compile --warnings-as-errors",
        "test --warnings-as-errors",
        "format --check-formatted",
        "credo --strict",
        "sobelow",
        "deps.audit",
        "dialyzer",
        "docs --warnings-as-errors"
      ]
    ]
  end

  defp dialyzer do
    [
      plt_add_apps: [:mix, :ex_unit],
      list_unused_filters: true
    ]
  end
end
