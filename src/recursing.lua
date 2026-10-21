--- Recursively iterates and looks up tables.
-- @module recursing
-- @author Roy Ratcliffe <roy@ratcliffe.me>
-- @copyright 2023, 2024
-- @license MIT
local _M = {}
local unpack = table.unpack or unpack -- Lua 5.1 compatibility

--- Recursively iterates table.
--
-- Recursively iterates all table pairs. Recursed pairs include tables, all
-- branches and leaves. Yields all types including functions. Recursed results
-- comprise an index path with a value. The path is a list of indices of string
-- or number type.
--
-- Tables may contain cycles and duplicates. The recursion removes both by
-- iterating only non-previously iterated tables.
--
-- Do not assume or depend on any particular ordering of pairs. Order is
-- indeterminate, even for otherwise ordered keys. Order depends on `pairs`
-- function for iteration of pairs within a table.
--
-- Filter by table-type mismatch for leaf pairs only, as follows.
--
--    for indices, value, typeofvalue in recursed.leavesandbranches(recursing) do
--      if typeofvalue ~= "table" then
--        --
--      end
--    end
--
-- The returned iterator yields three results:
--
-- * indices, one or more strings and numbers
-- * value
-- * value type, a string
--
-- @tparam tab recursing Table to recurse.
-- @treturn func Yields sub-indices, value, type of value.
function _M.leavesandbranches(recursing)
  assert(type(recursing) == "table")
  return coroutine.wrap(function()
    local uniterated = { { {}, recursing } }
    local iterated = {}
    repeat
      local indices, iterating = unpack(table.remove(uniterated))
      iterated[iterating] = true
      for index, value in pairs(iterating) do
        local subindices = { unpack(indices) }
        table.insert(subindices, index)
        local typeofvalue = type(value)
        if typeofvalue == "table" and not iterated[value] then
          table.insert(uniterated, { subindices, value })
        end
        coroutine.yield(subindices, value, typeofvalue)
      end
    until #uniterated == 0
  end)
end

--- Iterates leaf pairs only.
-- Skips branches, or any pair whose value is *not* itself a table.
-- @tparam tab recursing Table to recurse.
-- @treturn func Sub-indices, value, type of value.
function _M.leaves(recursing)
  return coroutine.wrap(function()
    for subindices, value, typeofvalue in _M.leavesandbranches(recursing) do
      if typeofvalue ~= "table" then
        coroutine.yield(subindices, value, typeofvalue)
      end
    end
  end)
end

--- Iterates branch pairs only.
-- Does *not* yield the type of value since the value is always `"table"`; type
-- implied by branch.
-- @tparam tab recursing Table to recurse.
-- @treturn func Indices-value iterator.
function _M.branches(recursing)
  return coroutine.wrap(function()
    for subindices, value, typeofvalue in _M.leavesandbranches(recursing) do
      if typeofvalue == "table" then
        coroutine.yield(subindices, value)
      end
    end
  end)
end

--- Apply sub-indices.
-- Looks up by sub-indices. Dereferences a multi-dimensional nested
-- array or table of values using sub-indices. Applies sub-indices in
-- the given order to nested tables. Answers a triple. Degenerates to
-- `nil, nil, indexed` when no sub-indices, parameter `...` empty.
-- @tparam tab recursing Table of indexed values.
-- @param ... Indices, zero or more.
-- @treturn ?tab Sub-indexed target table.
-- @return Sub-index in target table.
-- @return Value in target table at sub-index.
function _M.sub(recursing, ...)
  local subindexed
  local index
  for arg = 1, select("#", ...) do
    local subindex = select(arg, ...)
    if type(recursing) ~= "table" then return end
    subindexed = recursing
    index = subindex
    recursing = subindexed[index]
  end
  return subindexed, index, recursing
end

return _M
