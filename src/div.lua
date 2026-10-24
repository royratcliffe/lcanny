--- Division and modulo helpers.
-- @module div
local _M = {}

--- Divides using Lua's modulo operator.
-- For a nonzero divisor, the results satisfy `x = y * quotient + modulo`.
-- A nonzero modulo has the same sign as the divisor.
-- @tparam number x Dividend.
-- @tparam number y Nonzero divisor.
-- @treturn number Quotient, calculated as `(x - modulo) / y`.
-- @treturn number Modulo, calculated as `x % y`.
function _M.mod(x, y)
  local mod = x % y
  return (x - mod) / y, mod
end

--- Divides with a quotient adjustment for negative modulo.
-- Uses @{mod}, then subtracts one from the quotient if the modulo is
-- negative. The modulo is returned unchanged.
-- @tparam number a Dividend.
-- @tparam number b Nonzero divisor.
-- @treturn number Quotient from @{mod}, reduced by one when the modulo is negative.
-- @treturn number Unchanged modulo from @{mod}.
function _M.rem(a, b)
  local div, mod = _M.mod(a, b)
  return div - (mod < 0 and 1 or 0), mod
end

return _M
