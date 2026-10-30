--- Higher-order functions for socket operations with timeout handling.
-- Provides two higher-order functions for socket operations with timeout
-- handling. The retry logic is abstracted, making socket operations reusable
-- and composable. Use of a callback `to()` on timeout allows for flexible
-- handling, e.g., yielding in a coroutine. Only "timeout" errors are retried.
-- Other errors are returned immediately. Returned functions mirror the
-- underlying socket API, which is good for transparency.
--
-- If so:send or so:receive never succeed, e.g. the network is down, the loop
-- could be infinite. Consider applying a retry limit or timeout at higher
-- levels.
--
-- ## Example Usage
-- ```lua
-- local tcp = require("socket").tcp()
-- local so = require("so")
--
-- local send = so.sending(tcp, coroutine.yield)
-- local recv = so.recving(tcp, coroutine.yield)
-- ```
--
-- @copyright 2023, 2024, 2025
-- @author Roy Ratcliffe <roy@ratcliffe.me>
-- @module so
local _M = {}

--- Builds a higher-order sending function for a socket.
-- Returns a function that sends data on a socket, calling `to()` on timeout and
-- subsequently retrying.
-- @tparam socket so A non-blocking TCP socket.
-- @tparam func to A function to call on timeout, e.g. `coroutine.yield`.
-- @treturn func A function that sends data on the socket.
function _M.sending(so, to)
  return function(data, first, last)
    local sent, err, sending = so:send(data, first or 1, last)
    while not sent and err == "timeout" do
      to()
      sent, err, sending = so:send(data, sending + 1, last)
    end
    return sent, err
  end
end

--- Builds a higher-order receiving function for a socket.
-- Returns a function that receives data from a socket, calling `to()` on
-- timeout and subsequently retrying.
-- @tparam socket so A non-blocking TCP socket.
-- @tparam func to A function to call on timeout, e.g. `coroutine.yield`.
-- @treturn func A function that receives data from the socket.
function _M.recving(so, to)
  return function(pattern, prefix)
    local data, err, partial = so:receive(pattern, prefix)
    while not data and err == "timeout" do
      to()
      data, err, partial = so:receive(pattern, partial)
    end
    return data, err
  end
end

return _M
