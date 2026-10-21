--- Is or is not.
-- @module is
-- @author Roy Ratcliffe
-- @copyright 2024
-- @license MIT
local _M = {}

--- Is the string usable as a Lua identifier?
-- True if the string's characters conform to Lua identifier rules, that is,
-- starts with a letter or underscore, followed by letters, numbers or
-- underscores.
-- @tparam string str String to test.
-- @treturn bool Answers `true` if matches a Lua identifier; `false` otherwise.
function _M.identifier(str)
  return string.find(str, "^[%a_][%w_]*$") ~= nil
end

--- Array or non-array pairs?
-- Is the table an array where the keys comprise an integer sequence starting at
-- one? Note that this definition does not allow for sparse arrays with missing
-- integer indices.
-- @tparam tab indexed Table to examine.
-- @treturn bool Answers true if the given table is an array.
function _M.array(indexed)
  local index = 0
  for _ in pairs(indexed) do
    index = index + 1
    if indexed[index] == nil then return false end
  end
  return true
end

return _M
