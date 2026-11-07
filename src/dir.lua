--- Directories.
-- Provides directory iteration and path concatenation utilities.
-- @module dir
local _M = {
  SEP = "/"
}
local lfs = require "lfs"

--- Iterates non-dot directory entries.
-- Iterates all entries in a directory except for the special dot (`.`) and
-- double-dot (`..`) entries.
--
-- Automatically yields names as UTF-8 strings. They are converted from the
-- default system encoding.
-- @param ... Directory components.
-- @treturn func Non-dot directory entry iterator.
function _M.nondot(...)
  local dirname = _M.concat(...)
  return coroutine.wrap(function()
    for name in lfs.dir(dirname) do
      if name ~= "." and name ~= ".." then
        coroutine.yield(name)
      end
    end
  end)
end

--- Concatenates directory components.
-- Concatenates a sequence of directory path components. Skips `nil`s and single
-- dots; does not skip double dots.
-- @param ... Directory components.
-- @treturn string Concatenated directory components.
function _M.concat(...)
  local dirname = {}
  for index = 1, select("#", ...) do
    local value = select(index, ...)
    if value and value ~= "." then
      table.insert(dirname, value)
    end
  end
  return table.concat(dirname, _M.SEP)
end

--- Recursively iterates directory entries.
-- Iterates all non-directory entries in a directory and its subdirectories.
-- @param ... Directory components.
-- @treturn func Recursive directory entry iterator.
function _M.r(...)
  local dirname = _M.concat(...)
  return coroutine.wrap(function()
    local rels = { "." }
    repeat
      local rel = table.remove(rels)
      local abs = _M.concat(dirname, rel)
      for name in _M.nondot(abs) do
        local relname = _M.concat(rel, name)
        local absname = _M.concat(abs, name)
        if lfs.attributes(absname, "mode") == "directory" then
          table.insert(rels, relname)
        else
          coroutine.yield(abs, rel, name, absname, relname)
        end
      end
    until #rels == 0
  end)
end

--- Iterates non-directory entries in a directory.
-- Iterates all non-directory entries in a directory; does not recurse into
-- subdirectories.
-- @param ... Directory components.
-- @treturn func Non-directory entry iterator.
function _M.nonr(...)
  local dirname = _M.concat(...)
  local rel = "."
  return coroutine.wrap(function()
    local abs = _M.concat(dirname, rel)
    for name in _M.nondot(abs) do
      local relname = _M.concat(rel, name)
      local absname = _M.concat(abs, name)
      if lfs.attributes(absname, "mode") ~= "directory" then
        coroutine.yield(abs, rel, name, absname, relname)
      end
    end
  end)
end

return _M
