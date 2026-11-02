--- Pairs sorted by key.
-- @module sorting
-- @author Roy Ratcliffe <roy@ratcliffe.me>
-- @copyright 2023, 2024
-- @license MIT
local _M = {}

local function ordered(sorted, ordering)
  local index = sorted[1][ordering + 1]
  return index and ordering + 1, index, sorted[2][index]
end

--- Iterates table entries in sorted key order.
-- Collects and sorts the table's keys before returning an iterator over the
-- corresponding key-value pairs.
-- @tparam tab indexed Table whose keys are sorted.
-- @tparam ?func comparing Optional function that compares two keys.
-- @treturn func Iterator returning the next control index, key and value.
-- @treturn tab State containing the sorted keys and original table.
-- @treturn number Initial control index, zero.
function _M.ipairs(indexed, comparing)
  local indices = {}
  for index, _ in pairs(indexed) do
    table.insert(indices, index)
  end
  table.sort(indices, comparing)
  return ordered, { indices, indexed }, 0
end

return _M
