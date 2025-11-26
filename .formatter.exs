# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  plugins: [Spark.Formatter],
  import_deps: [:ash, :spark, :ash_agent],
  locals_without_parens: [
    # AshAgentStudio DSL - agent_studio section
    label: 1,
    description: 1,
    group: 1,
    redact_fields: 1,

    # AshAgentStudio DSL - input entity
    input: 1,
    input: 2
  ],
  export: [
    locals_without_parens: [
      # AshAgentStudio DSL - agent_studio section
      label: 1,
      description: 1,
      group: 1,
      redact_fields: 1,

      # AshAgentStudio DSL - input entity
      input: 1,
      input: 2
    ]
  ]
]
