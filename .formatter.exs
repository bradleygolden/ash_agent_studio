[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  plugins: [Spark.Formatter],
  import_deps: [:ash, :spark, :ash_agent],
  locals_without_parens: [
    redact_fields: 1,
    ash_agent_studio: 1,
    ash_agent_studio: 2
  ],
  export: [
    locals_without_parens: [
      redact_fields: 1,
      ash_agent_studio: 1,
      ash_agent_studio: 2
    ]
  ]
]
