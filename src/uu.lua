--- Universally Unique.
-- Generates universally unique identifiers (UUIDs).
-- @module uu
local _M = {
  SEQ = 0
}

-- Seed the random number generator. This uses the current time and clock to
-- generate a unique seed.
-- Only do this once per process to avoid reseeding the PRNG multiple times.
-- WARNING: os.time() has only second resolution. Processes loading this module
-- in the same second can seed identical random sequences and generate duplicate
-- identifiers. This also reseeds Lua's shared PRNG; uniqueness is not guaranteed.
if math.randomseed then
  math.randomseed(os.time() + os.clock() * 100000)
end

--- Generates a new UUID.
-- Uses the current time, a random number, and a sequence number to generate a
-- unique identifier.
-- @treturn string New UUID.
function _M.id()
  _M.SEQ = _M.SEQ + 1
  return string.format("%d%06d%04d", os.time(), math.random(0, 999999), _M.SEQ % 10000)
end

return _M
