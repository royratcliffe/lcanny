--- RESP version-2 protocol.
-- Implements RESP version-2 calling, sending and receiving functions.
-- @module resp.v2
local _M = {
  send = require "resp.v2.send",
  recv = require "resp.v2.recv"
}
local hi = require "hi"
local so = require "so"
local interleaving = require "interleaving"
local collecting = require "collecting"

--- Builds a Redis calling function.
-- Builds a Redis calling function using the given sending and receiving
-- sub-functions. The resulting function sends a Redis command and then receives
-- a Redis reply.
-- @treturn ?any Redis reply; possibly RESP null.
-- @treturn ?string Receiving error, if any.
function _M.calling(tcp)
  return hi.calling(function(...)
    return _M.send.recursive(function(...)
      return tcp:send(...)
    end, ...)
  end, function()
    return _M.recv.recursive(function(...)
      return tcp:receive(...)
    end)
  end)
end

--- Establishes a TCP socket for thread-based RESP version-2 communication.
-- Sets up a TCP socket for thread-based RESP version-2 calling, sending and
-- receiving. Calling amounts to one asserted send followed by one non-asserted
-- receive. The resulting functions capture the non-blocking TCP socket.
-- @treturn func Calling function.
-- @treturn func Sending function.
-- @treturn func Receiving function.
function _M.resuming(tcp)
  assert(tcp:settimeout(0))
  local sending = function(...)
    return _M.send.recursive(so.sending(tcp, coroutine.yield), ...)
  end
  local recving = function()
    return _M.recv.recursive(so.recving(tcp, coroutine.yield))
  end
  return hi.calling(sending, recving), sending, recving
end

--- Performs a RESP scan.
-- Captures the Redis calling function and the scan arguments. Lua cannot
-- capture variable arguments across nested functions.
function _M.scan(call, ...)
  local args = { ... }
  return coroutine.wrap(function()
    local cursor = "0"
    repeat
      local keys
      cursor, keys = unpack(assert(call { "SCAN", cursor, unpack(args) }))
      for _, key in ipairs(keys) do
        coroutine.yield(key)
      end
    until cursor == "0"
  end)
end

function _M.hscan(call, key, ...)
  local args = { ... }
  return coroutine.wrap(function()
    local cursor = "0"
    repeat
      local fields
      cursor, fields = unpack(assert(call { "HSCAN", key, cursor, unpack(args) }))
      for _, field in ipairs(fields) do
        coroutine.yield(field)
      end
    until cursor == "0"
  end)
end

function _M.sscan(call, key, ...)
  local args = { ... }
  return coroutine.wrap(function()
    local cursor = "0"
    repeat
      local members
      cursor, members = unpack(assert(call { "SSCAN", key, cursor, unpack(args) }))
      for _, member in ipairs(members) do
        coroutine.yield(member)
      end
    until cursor == "0"
  end)
end

--- Iterates Redis stream entries.
-- Each entry is yielded as a triplet: the stream key, the entry stamp,
-- and the entry fields as a table.
-- @tparam tab received Array of streamed and stamped entries.
-- @treturn func Redis stream entry iterator.
function _M.entries(received)
  return coroutine.wrap(function()
    for _, streamed in ipairs(received) do
      local key, entries = unpack(streamed)
      for _, stamped in ipairs(entries) do
        local stamp, entry = unpack(stamped)
        -- Collapse the interleaved array of fields into a table of field-value
        -- pairs. Fields must be unique within the entry. Redis itself performs
        -- a similar collapse when adding entries to a stream.
        coroutine.yield(key, stamp, collecting.ifields(interleaving.ipairs(entry)))
      end
    end
  end)
end

return _M
