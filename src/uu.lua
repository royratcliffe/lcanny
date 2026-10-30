--- Universally Unique.
-- Generates universally unique identifiers (UUIDs).
-- @module uu
local _M = {
  SEQ = 0
}

math.randomseed(os.time())

--- Generates a new UUID.
-- Uses the current time, a random number, and a sequence number to generate a
-- unique identifier.
-- @treturn string New UUID.
function _M.id()
  _M.SEQ = _M.SEQ + 1
  return string.format("%d%06d%04d", os.time(), math.random(0, 999999), _M.SEQ % 10000)
end

return _M
