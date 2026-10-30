--- Operates on filenames by file mode.
-- Temporarily opens files for reading or writing. Automatically closes
-- temporarily-opened files even on error.
-- @module filename
local _M = {}

--- Closes a file and returns additional values.
-- @tparam file file The file to close.
-- @param ... Values to return after successfully closing the file.
-- @treturn boolean Whether the file was closed successfully.
-- @treturn string Error message if the file could not be closed.
-- @return ... Additional values passed in if closing succeeded.
local function close(file, ...)
  local closed, err = file:close()
  if not closed then return closed, err end
  return ...
end

--- Metatable for read operations.
-- @field mode The mode to append to the read operation.
local __read = {}

--- Prepares a file read operation.
-- Appends the given mode to the next open for reading.
-- @tparam string|nil mode The mode to append to the read operation.
-- @treturn table Prepared read operation.
function _M.read(mode)
  return setmetatable({ mode = mode or "" }, __read)
end

--- Performs a read.
-- @tparam string filename Name of file to read.
-- @param ... What to read.
-- @return ... Read values.
function __read:__call(filename, ...)
  local file, err = io.open(filename, "r" .. self.mode)
  if not file then return file, err end
  return close(file, file:read(...))
end

--- Metatable for write operations.
-- @field mode The mode to append to the write operation.
local __write = {}

--- Prepares a file write operation.
-- Appends the given mode to the next open for writing.
-- @tparam string mode The mode to append to the write operation.
-- @treturn table Prepared write operation.
function _M.write(mode)
  return setmetatable({ mode = mode }, __write)
end

--- Performs a write.
-- @tparam string filename Name of file to write.
-- @param ... What to write.
-- @return ... Write results.
function __write:__call(filename, ...)
  local file, err = io.open(filename, "w" .. self.mode)
  if not file then return file, err end
  return close(file, file:write(...))
end

return _M
