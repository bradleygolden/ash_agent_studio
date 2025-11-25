import Config

config :ash_baml,
  clients: [
    dev: {AshAgentStudio.BamlClients.Dev, baml_src: "dev/baml_src"}
  ]

config :ash_agent_studio,
  generators: [timestamp_type: :utc_datetime]

config :phoenix, :json_library, Jason

if config_env() == :dev do
  config :ash_agent_studio, AshAgentStudio.Dev.Endpoint,
    url: [host: "localhost"],
    adapter: Bandit.PhoenixAdapter,
    server: true,
    http: [ip: {127, 0, 0, 1}, port: 4000],
    check_origin: false,
    code_reloader: true,
    debug_errors: true,
    secret_key_base: "dev_secret_key_base_that_is_at_least_64_bytes_long_for_development_only",
    live_view: [signing_salt: "dev_salt"],
    pubsub_server: AshAgentStudio.PubSub,
    watchers: [
      esbuild: {Esbuild, :install_and_run, [:ash_agent_studio, ~w(--sourcemap=inline --watch)]},
      tailwind: {Tailwind, :install_and_run, [:ash_agent_studio, ~w(--watch)]}
    ],
    live_reload: [
      patterns: [
        ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
        ~r"lib/ash_agent_studio/.*(ex|heex)$",
        ~r"dev/.*(ex)$"
      ]
    ]

  config :phoenix_live_view,
    debug_heex_annotations: true,
    enable_expensive_runtime_checks: true

  config :esbuild,
    version: "0.17.11",
    ash_agent_studio: [
      args:
        ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
      cd: Path.expand("../assets", __DIR__),
      env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
    ]

  config :tailwind,
    version: "3.4.0",
    ash_agent_studio: [
      args: ~w(
        --config=tailwind.config.js
        --input=css/app.css
        --output=../priv/static/assets/app.css
      ),
      cd: Path.expand("../assets", __DIR__)
    ]
end
