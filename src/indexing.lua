--- Indexing tables.
-- You can:
--
-- 1.  Find a value by an index with some default.
-- 2.  Find a nested value using a sequence of indices.
-- @module indexing
-- @author Roy Ratcliffe
-- @copyright 2024
-- @license MIT
local _M = {}

--- Finds the value of an index.
function _M.of(indexing, index, default)
  local value = indexing[index]
  if value == nil then
    value = type(default) == "function" and default(index) or default
    indexing[index] = value
  end
  return value
end

--- Finds nested indices.
-- Assumes an empty table as the default. The terminal index does **not** need
-- to select a table, but the intermediate indices must select a table;
-- otherwise, the function raises an error.
function _M.findof(indexing, ...)
  for index = 1, select("#", ...) do
    indexing = assert(_M.of(indexing, select(index, ...), {}))
  end
  return indexing
end

return _M
