--- Redis client connection.
-- Loads a Redis client that connects to the local Redis server. The host can be
-- overridden by setting the REDISCLI_HOST environment variable. The port
-- defaults to 6379. The connection exposes a `call` function that can be used
-- to send commands to Redis using RESP version 2 in blocking mode.
-- @module redis
local socket = {
  core = require "socket.core"
}
local resp = require "resp"

-- Connect to Redis server.
-- @return table Redis client connection.
local tcp = assert(socket.core.tcp())
assert(tcp:connect(os.getenv("REDISCLI_HOST") or "localhost", 6379))
return {
  call = resp.v2.calling(tcp)
}
