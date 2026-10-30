--- RESP version-2 sending.
-- Sends by Lua type: number, string or table. Numbers are sent as integers for
-- version 2. Strings go out as bulk strings. Tables transmit by recursion as
-- arrays of items which are themselves numbers, strings or sub-tables.
local _M = {}

--- Sends a RESP version-2 message recursively.
-- @tparam func sending Function for abstractly sending.
-- @param data Message to send.
-- @treturn number Number of bytes sent.
function _M.recursive(sending, data)
  return assert(_M[type(data)])(sending, data)
end

function _M.number(sending, data)
  return sending(table.concat { ":", data, "\r\n" })
end

function _M.string(sending, data)
  return sending(table.concat { "$", #data, "\r\n", data, "\r\n" })
end

--- Sends a RESP version-2 array.
-- Tables are sent as arrays, ignoring indices. Assume that the hash operator
-- delivers the correct number of indexed pairs.
function _M.table(sending, data)
  local sent = assert(sending(table.concat { "*", #data, "\r\n" }))
  for _, item in ipairs(data) do
    sent = sent + assert(_M.recursive(sending, item))
  end
  return sent
end

return _M
