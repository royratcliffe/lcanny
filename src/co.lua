--- Coroutine list module.
-- This module provides a thread container that allows you to run multiple
-- threads in a single call. You can add new threads to the list by calling the
-- list with a function and its arguments. The list will resume all threads that
-- have been added, and remove any that have finished running.
-- @module co
local _M = {}

--- Logs a coroutine error.
-- Replace this function to route errors to an application logger.
-- @tparam string message Error message.
function _M.log(message)
  assert(io.stderr:write(message, "\n"))
end

--- Coroutine module metatable.
-- @field __call Allows you to call the module to create a new thread list.
local __M = {}

--- Thread list metatable.
-- This metatable defines the behaviour of the thread list. It allows you to
-- call the list with a function and its arguments to add a new thread, and
-- it will resume all threads that have been added, removing any that have
-- finished running.
local __threads = {}

--- Operator for calling the thread list.
-- This operator allows you to add a new thread to the list by calling the
-- list with a function and its arguments. It will also resume all threads
-- that have been added, and remove any that have finished running.
-- @param ... The function to run in a new coroutine, followed by any
-- arguments to pass to that function.
function __threads:__call(...)
  -- Step 1: Accept a function to run in a coroutine. The first argument is the
  -- function to run, and any additional arguments are passed to that function.
  if select("#", ...) ~= 0 then
    local thread = assert(coroutine.create((select(1, ...))))
    local status, result = coroutine.resume(thread, select(2, ...))
    if status then
      table.insert(self, thread)
    elseif result then
      _M.log(tostring(result))
    end
  end
  -- Step 2: Resume all coroutines that have been added to the list. Collect the
  -- indices of all coroutines that have finished running. Insert indices at the
  -- beginning of the list to avoid shifting issues when removing them later.
  local dead = {}
  for index, value in ipairs(self) do
    if coroutine.status(value) == "dead" then
      table.insert(dead, index)
    else
      local status, result = coroutine.resume(value)
      if not status and result then
        _M.log(tostring(result))
      end
    end
  end
  -- Step 3: Remove all dead coroutines from the list. The indices are inserted
  -- at the beginning of the list in Step 2 to avoid reindexing issues when
  -- removing them. The list is traversed in order, so these indices are removed
  -- from the end of the list first; hence no shifting issues occur.
  for index = #dead, 1, -1 do
    table.remove(self, dead[index])
  end
end

--- Constructs a new coroutine list.
-- @param ... Arguments to pass to the first coroutine. The first argument is the
-- function to run, and any additional arguments are passed to that function.
-- @treturn table A new coroutine list.
function __M:__call(...)
  local threads = setmetatable({}, __threads)
  if select("#", ...) ~= 0 then
    threads(...)
  end
  return threads
end

return setmetatable(_M, __M)
