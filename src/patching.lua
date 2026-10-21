--- Creates and applies patches between Lua tables.
-- @module patching
-- @author Roy Ratcliffe
-- @copyright 2024
-- @license MIT
local _M = {}

--- Creates a patch that transforms `lhs` into `rhs`.
-- Nested tables are diffed recursively. Returns nil when the tables are equal.
-- @tparam table lhs Original table.
-- @tparam table rhs Target table.
-- @treturn ?table Patch, or nil when no changes are needed.
function _M.diff(lhs, rhs)
  local patched = {}
  local changed = {}
  local removed = {}
  for index, left in pairs(lhs) do
    local right = rhs[index]
    if right == nil then
      removed[index] = left
    elseif type(left) == "table" and type(right) == "table" then
      patched[index] = _M.diff(left, right)
    elseif left ~= right then
      changed[index] = right
    end
  end
  for index, right in pairs(rhs) do
    local left = lhs[index]
    if left == nil then
      changed[index] = right
    end
  end
  local patch = {
    patched = next(patched) and patched or nil,
    changed = next(changed) and changed or nil,
    removed = next(removed) and removed or nil
  }
  return next(patch) and patch or nil
end

--- Applies a patch to a table in place.
-- @tparam table patching Table to update.
-- @tparam ?table patch Patch returned by `diff`.
function _M.apply(patching, patch)
  if patch then
    if patch.patched then
      for index, value in pairs(patch.patched) do
        local indexed = patching[index]
        if indexed == nil then
          indexed = {}
          patching[index] = indexed
        end
        _M.apply(indexed, value)
      end
    end
    if patch.changed then
      for index, value in pairs(patch.changed) do
        patching[index] = value
      end
    end
    if patch.removed then
      for index, _ in pairs(patch.removed) do
        patching[index] = nil
      end
    end
  end
end

return _M
