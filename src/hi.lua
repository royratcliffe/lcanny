--- Half-duplex helper.
-- Provides a helper to build half-duplex calling functions using sending and
-- receiving sub-functions.
-- @module hi
local _M = {}

--- Builds a half-duplex calling function.
-- Builds a half-duplex calling function using the given sending and receiving
-- sub-functions. The function sends a half-duplex command and then receives a
-- half-duplex reply.
--
-- The call operation asserts errors only during the send phase, never the
-- receive phase.
-- @tparam func sending Function used to send.
-- @tparam func recving Function used to receive.
-- @treturn ?any Received reply.
-- @treturn ?string Receiving error, if any.
function _M.calling(sending, recving)
  return function(command)
    assert(sending(command))
    return recving()
  end
end

return _M
