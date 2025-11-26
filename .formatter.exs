# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  plugins: [Spark.Formatter],
  import_deps: [:ash, :spark, :ash_agent],
  locals_without_parens: [
    redact_fields: 1
  ],
  export: [
    locals_without_parens: [
      redact_fields: 1
    ]
  ]
]
