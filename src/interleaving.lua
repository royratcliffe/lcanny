--- Interleaved arrays by iterating.
-- @module interleaving
-- @author Roy Ratcliffe
-- @copyright 2024
-- @license MIT
local _M = {}

--- Next index, first and second values.
-- @tparam tab interleaved Array of interleaved pairs.
-- @tparam number index Current index.
-- @treturn number Next index.
-- @return First interleaved value.
-- @return Second interleaved value.
function _M.inext(interleaved, index)
  local first = interleaved[index + 1]
  return first ~= nil and index + 2 or nil, first, interleaved[index + 2]
end

--- Iterates an interleaved array of pairs.
-- @tparam tab interleaved Array of interleaved pairs.
-- @treturn func Answers the next index, first and second values.
-- @treturn tab Array of pairs to iterate.
-- @treturn number Initial iteration index of zero.
function _M.ipairs(interleaved)
  return _M.inext, interleaved, 0
end

return _M
