class ChatReply {
  content string
}

function ChatAgent(message: string) -> ChatReply {
  client OllamaClient
  prompt #"
    You are a helpful assistant in the Ash Agent Studio playground.
    Respond to the user's message concisely and helpfully.

    User message: {{ message }}

    {{ ctx.output_format }}
  "#
}
