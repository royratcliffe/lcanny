--- RESP version-2 receiving.
-- Receives for version-2 RESP answers one of the following:
--
-- * a number,
-- * a simple error,
-- * a simple string,
-- * a bulk string or a null; else
-- * an array.
--
-- @module resp.v2.recv
local _M = {}
local resp = {
  null = require "resp.null"
}

--- Receives a RESP version-2 message recursively.
-- Receives one of the following:
--
-- * a number,
-- * a simple error,
-- * a simple string,
-- * a bulk string, or
-- * an array of recursive items.
--
-- Receives a single line first. It raises an error if there is no first line.
-- Receiving a simple error string triggers a Lua error at the next assertion.
--
-- How does the reply distinguish between an error and a null bulk string? Null
-- bulk strings answer `resp.null` instead, a table by default.
--
-- The outer recursion does not assert. It can return an error, a simple error
-- string; hence, the caller must apply an outer assertion if necessary or
-- otherwise not assume success. An aggregate array cannot contain error strings
-- because the aggregation asserts every item.
-- @tparam func recving Function for abstractly receiving.
function _M.recursive(recving)
  local data = assert(recving("*l"))
  return assert(_M[data:sub(1, 1)])(recving, data:sub(2))
end

--- Receives a RESP version-2 number.
-- Handles the `:` reply prefix.
-- @function number_reply
-- @tparam func recving Function for abstractly receiving; unused for this reply.
-- @tparam string rest Text after the colon prefix.
-- @treturn number Received number.
_M[":"] = function(_, rest)
  return assert(tonumber(rest))
end

--- Receives a RESP version-2 simple error.
-- Returns the error message as the second result rather than raising an error.
-- Handles the `-` reply prefix.
-- @function error_reply
-- @tparam func recving Function for abstractly receiving; unused for this reply.
-- @tparam string rest Error message after the prefix.
-- @treturn nil No reply value.
-- @treturn string Error message.
_M["-"] = function(_, rest)
  return nil, rest
end

--- Receives a RESP version-2 simple string.
-- Handles the `+` reply prefix.
-- @function simple_string_reply
-- @tparam func recving Function for abstractly receiving; unused for this reply.
-- @tparam string rest Text after the plus prefix.
-- @treturn string Received string.
_M["+"] = function(_, rest)
  return rest
end

--- Receives a RESP version-2 bulk string.
-- Receives the number of bytes specified by the length prefix, followed by a
-- line ending. A negative length represents RESP null.
-- Handles the `$` reply prefix.
-- @function bulk_string_reply
-- @tparam func recving Function for abstractly receiving.
-- @tparam string rest Text after the dollar prefix.
-- @treturn any Received string, or RESP null.
_M["$"] = function(recving, rest)
  local len = assert(tonumber(rest))
  if len < 0 then return resp.null end
  local data = assert(recving(len))
  assert(recving("*l"))
  return data
end

--- Receives a RESP version-2 array.
-- Receives an array of recursive items. The length of the array is specified
-- by the first line after the `*` character. Each item is received recursively.
-- A null array is represented by a negative length.
-- @function array_reply
-- @tparam func recving Function for abstractly receiving.
-- @tparam string rest The rest of the first line after the `*` character.
-- @treturn ?tab Array of received items; possibly RESP null.
_M["*"] = function(recving, rest)
  local len = assert(tonumber(rest))
  if len < 0 then return resp.null end
  local data = {}
  for _ = 1, len do
    -- Recursively receive each item in the array. Do not assert here;
    -- let the recursive function handle errors. An array may legally
    -- contain null items, e.g., `*2\r\n$-1\r\n$3\r\nfoo\r\n` following
    -- the RESP specification---an array of two bulk strings, the first
    -- being null and the second being "foo". EXEC results containing a
    -- failed command will include an error item in the array.
    table.insert(data, _M.recursive(recving))
  end
  return data
end

return _M
