local lapis = require("lapis")
local app = lapis.Application()

app:get("/", function() -- Sadly we can't get away with no routes.
  return "Welcome to Lapis " .. require("lapis.version")
end)

app.handle_404 = function() -- 404s are actually handled by app.lua, not this.
  return "Ack, you don't have permission to see that!<br>Go away!"
end

return app
