--- Safe functions.
-- @module safely
local _M = {}

--- Loads and calls Lua within an environment.
-- Loads a chunk of Lua from the given file, then executes it within a
-- function environment using a protected call. Creates a new empty environment if none provided.
-- Ignores any errors that occur during loading or execution, and returns the
-- environment used for the loaded chunk.
-- @tparam string filename Name of file to load and execute.
-- @tparam[opt] table env Environment to use for the loaded chunk.
-- @treturn table Environment used for the loaded chunk.
function _M.dofile(filename, env)
  env = env or {}
  local calling
  if setfenv then
    calling = loadfile(filename)
    if calling then setfenv(calling, env) end
  else
    -- In Lua 5.2 and later, setfenv is not available, so pass the
    -- environment directly to loadfile. Pass "t" as the mode to
    -- indicate text-only mode.
    calling = loadfile(filename, "t", env)
  end
  if calling then pcall(calling) end
  return env
end

return _M
