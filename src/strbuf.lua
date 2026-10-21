--- Builds strings incrementally using a callable buffer.
-- @module strbuf
-- @author Roy Ratcliffe
-- @copyright 2024
-- @license MIT
local _M = {}

--- Creates a string-buffer constructor.
-- @tparam ?string defsep Default separator used by `tostring`.
-- @treturn func Constructor that creates a buffer.
function _M.factory(defsep)
  local __strbuf = {}

  function __strbuf:__tostring()
    return table.concat(self, defsep)
  end

  function __strbuf:__div(sep)
    if getmetatable(self) ~= __strbuf then self, sep = sep, self end
    return table.concat(self, sep)
  end

  function __strbuf:__unm()
    return self / defsep
  end

  function __strbuf:__call(str)
    table.insert(self, str)
    return self
  end

  return function(...)
    return setmetatable({...}, __strbuf)
  end
end

--- Creates a string buffer using the default separator.
-- @field new
_M.new = _M.factory()

return _M
