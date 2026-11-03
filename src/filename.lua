--- Operates on filenames by file mode.
-- Temporarily opens files for reading or writing. Always attempts to close
-- temporarily-opened files, then rethrows read or write errors unchanged.
-- @module filename
local _M = {}

---- Closes a file after a protected operation.
-- @tparam file file The file to close.
-- @tparam boolean ok Whether the operation succeeded.
-- @param ... Operation results or the error to rethrow.
-- @return ... Operation results, or nil and a close error.
local function close(file, ok, ...)
  local closeok, closed, err = pcall(file.close, file)
  -- Preserve the operation error even if closing also fails.
  if not ok then error((...), 0) end
  if not closeok then error(closed, 0) end
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
-- Step 1: Open the file for reading with the specified mode. If opening fails,
-- return the error immediately.
-- Step 2: Read from the file using the specified arguments. The read operation
-- is protected with pcall to catch any errors. The file is closed afterwards,
-- and any error propagates correctly.
-- @tparam string filename Name of file to read.
-- @param ... What to read.
-- @return ... Read values.
function __read:__call(filename, ...)
  local file, err = io.open(filename, "r" .. self.mode)
  if not file then return file, err end
  return close(file, pcall(file.read, file, ...))
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
  return close(file, pcall(file.write, file, ...))
end

return _M
