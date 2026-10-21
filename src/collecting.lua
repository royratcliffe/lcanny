--- Collected arrays and tables by iterating.
-- @module collecting
-- @author Roy Ratcliffe
-- @copyright 2024
-- @license MIT
local _M = {}

--- Collects values by iterating.
-- Lua 5.1 allows table insertion of `nil` values.
-- @param ... Iterator parameters.
-- @treturn tab Array of values.
function _M.values(...)
  local collected = {}
  for value in ... do
    table.insert(collected, value)
  end
  return collected
end

--- Collects indexed values by iterating.
-- @param ... Iterator parameters.
-- @treturn tab Array of values.
function _M.ivalues(...)
  local collected = {}
  for _, value in ... do
    table.insert(collected, value)
  end
  return collected
end

--- Collects pairs by iterating.
-- @param ... Iterator parameters.
-- @treturn tab Table of pairs.
function _M.fields(...)
  local collected = {}
  for index, value in ... do
    collected[index] = value
  end
  return collected
end

--- Collects indexed pairs by iterating.
-- @param ... Iterator parameters.
-- @treturn tab Table of pairs.
function _M.ifields(...)
  local collected = {}
  for _, index, value in ... do
    collected[index] = value
  end
  return collected
end

return _M
