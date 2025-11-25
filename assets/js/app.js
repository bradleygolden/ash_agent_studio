// LiveView JavaScript setup
import { Socket } from "../../deps/phoenix/priv/static/phoenix.mjs"
import { LiveSocket } from "../../deps/phoenix_live_view/priv/static/phoenix_live_view.esm.js"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  longPollFallbackMs: 2500
})

// Connect if there are any LiveViews on the page
liveSocket.connect()

// Expose liveSocket on window for debugging
window.liveSocket = liveSocket
