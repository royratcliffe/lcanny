local _M = {}

function _M.mod(x, y)
  local mod = x % y
  return (x - mod) / y, mod
end

function _M.rem(a, b)
  local div, mod = _M.mod(a, b)
  return div - (mod < 0 and 1 or 0), mod
end

return _M
