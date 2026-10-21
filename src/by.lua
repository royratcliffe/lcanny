--- Group by.
-- @module by
-- @author Roy Ratcliffe
-- @copyright 2024
-- @license MIT
local _M = {}

--- Groups an array of values by the results of a given function.
-- Transforms an array to a set of pairs. Groups the values only. Ignores keys.
-- @tparam func indexforvalue Function to group by.
-- @tparam tab values Array of values to group.
-- @treturn tab Array of group arrays.
function _M.group(indexforvalue, values)
  local groups = {}
  for _, value in ipairs(values) do
    local index = indexforvalue(value, groups)
    local group = groups[index]
    if group then
      table.insert(group, value)
    else
      groups[index] = { value }
    end
  end
  return groups
end

return _M
