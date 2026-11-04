--- Tools for working with search path strings.
-- Search path strings are used by Lua to locate modules and C libraries. This
-- module provides functions for merging values into search path strings while
-- ensuring that each value is unique in the resulting string.
-- @module searchpath
local _M = {}

--- Merges a value into an indexed table if it does not already
--- exist in the table.
-- @tparam table indexed The indexed table to merge into.
-- @tparam any merging The value to merge into the indexed table.
local function imerge(indexed, merging)
  for _, value in ipairs(indexed) do
    if value == merging then
      return
    end
  end
  table.insert(indexed, merging)
end

--- Merges zero or more values into a path string, ensuring that each
--- value is unique in the resulting path string.
-- @tparam string path The original path string.
-- @tparam {string,...} ... Zero or more values to append to the path string.
-- @treturn string The resulting path string with unique values.
function _M.mergewith(path, ...)
  local matches = {}
  for match in string.gmatch(path, "([^;]+)") do
    imerge(matches, match)
  end
  for index = 1, select("#", ...) do
    imerge(matches, select(index, ...))
  end
  return table.concat(matches, ";")
end

return _M
