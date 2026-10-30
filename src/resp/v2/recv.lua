-- RESP version-2 receiving.
-- Receives for version-2 RESP answers one of the following:
--
-- * a number,
-- * a simple error,
-- * a simple string,
-- * a bulk string or a null; else
-- * an array.
--
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

_M[":"] = function(_, rest)
  return assert(tonumber(rest))
end

_M["-"] = function(_, rest)
  return nil, rest
end

_M["+"] = function(_, rest)
  return rest
end

_M["$"] = function(recving, rest)
  local len = assert(tonumber(rest))
  if len < 0 then return resp.null end
  local data = assert(recving(len))
  assert(recving("*l"))
  return data
end

_M["*"] = function(recving, rest)
  local len = assert(tonumber(rest))
  local data = {}
  for _ = 1, len do
    table.insert(data, assert(_M.recursive(recving)))
  end
  return data
end

return _M
