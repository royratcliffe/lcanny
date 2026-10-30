--- Filtering pairs.
-- This module provides a function to filter pairs by iterating over an
-- iterator. It allows for selective inclusion of pairs based on a filter
-- function that evaluates each pair's index and value.
-- @module filtering
-- @author Roy Ratcliffe
local _M = {}

--- Filters pairs by iterating.
-- This function takes a filter function and an iterator, returning a table of
-- pairs that match the filter criteria. The filter function should accept two
-- parameters: the index and value of each pair, returning true for pairs that
-- should be included.
-- @tparam func filter Function that filters pairs based on index and value.
-- @param ... Iterator parameters.
-- @treturn tab Table of filtered pairs.
function _M.fields(filter, ...)
  local filtered = {}
  for index, value in ... do
    if filter(index, value) then
      filtered[index] = value
    end
  end
  return filtered
end

return _M
