--- Proleptic Gregorian calendar calculations.
-- Years use astronomical numbering: year 0 exists, is a leap year, and is
-- preceded by year -1. Calendar inputs are integers. Months and days of month
-- are one-based; days of year are zero-based.
--
-- Absolute days count from January 1 of year 0, not the Unix epoch.
-- January 1, 1970 is absolute day 719528. Calculations are independent of
-- time zones and daylight saving time.
--
-- `MDAY` contains common-year month lengths, and `YDAY` contains the zero-based
-- starting day of each common-year month. Both are indexed from 1 to 12.
-- `MCM` is 693961, the absolute day of January 1, 1900.
-- @module leap
local _M = {
  MDAY = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 },
  YDAY = { 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334 },
  MCM = 693961
}
local div = require "div"

--- Is a year a leap year?
-- A year is a leap year if it is divisible by 4, except for years that
-- are divisible by 100, unless they are also divisible by 400.
-- @tparam number y Integer year, including zero or negative years.
-- @treturn boolean Whether the year is a leap year.
function _M.year(y)
  return y % 4 == 0 and (y % 100 ~= 0 or y % 400 == 0)
end

--- Returns the leap-day adjustment for a year.
-- This is the numeric equivalent of @{year}.
-- @tparam number y Integer year.
-- @treturn number 1 for a leap year, otherwise 0.
function _M.add(y)
  return _M.year(y) and 1 or 0
end

--- Counts leap years through the given year.
-- Returns `floor(y / 4) - floor(y / 100) + floor(y / 400)`.
-- For positive years, this counts leap years from 1 through `y`, inclusive.
-- The formula extends to zero and negative years without counting year 0
-- as an extra leap day: `thru(0)` is 0 and `thru(-1)` is -1.
-- @tparam number y Integer year, included in the count.
-- @treturn number Signed cumulative leap-year count.
function _M.thru(y)
  return div.mod(y, 4) - div.mod(y, 100) + div.mod(y, 400)
end

--- Returns the absolute day of January 1 of a year.
-- Year 0 starts at absolute day 0; year 1 starts at absolute day 366.
-- @tparam number y Integer year.
-- @treturn number Days from January 1 of year 0 to January 1 of `y`.
function _M.day(y)
  return y * 365 + _M.thru(y - 1) + 1
end

--- Normalises a year and zero-based day of year.
-- Negative days move into earlier years; overflowing days move into later
-- years. The resulting day is in 0..364 for a common year or 0..365 for a
-- leap year.
-- @tparam number y Integer starting year.
-- @tparam number day Integer day offset from January 1 of `y`.
-- @treturn number Normalised year.
-- @treturn number Normalised zero-based day of year.
-- @usage
-- local leap = require "leap"
-- local year, day = leap.off(2024, 366) -- 2025, 0
function _M.off(y, day)
  local days = 365 + _M.add(y)
  while day < 0 or day >= days do
    -- Divide the day by 365 or 366 to get the number of years to offset.
    local y_ = y + div.mod(day, days)
    day = day + _M.day(y) - _M.day(y_)
    y = y_
    days = 365 + _M.add(y)
  end
  return y, day
end

--- Returns the number of days in a month.
-- February has 29 days in leap years and 28 otherwise.
-- @tparam number y Integer year.
-- @tparam number mon Integer month in 1..12; not normalised.
-- @treturn number Month length.
function _M.mday(y, mon)
  return _M.MDAY[mon] + (mon == 2 and _M.add(y) or 0)
end

--- Returns the zero-based day of year at the start of a month.
-- Includes February's extra day for months after February in leap years.
-- @tparam number y Integer year.
-- @tparam number mon Integer month in 1..12; not normalised.
-- @treturn number Day offset of the first day of the month.
function _M.yday(y, mon)
  return _M.YDAY[mon] + (mon > 2 and _M.add(y) or 0)
end

--- Converts a year and zero-based day of year to a calendar date.
-- Normalises negative or overflowing days using @{off}.
-- @tparam number y Integer starting year.
-- @tparam number day Integer day offset from January 1 of `y`.
-- @treturn number Normalised year.
-- @treturn number Month in 1..12.
-- @treturn number One-based day of month.
function _M.date(y, day)
  y, day = _M.off(y, day)
  for mon = 1, 12 do
    local mday = _M.mday(y, mon)
    if day < mday then return y, mon, day + 1 end
    day = day - mday
  end
end

--- Converts a calendar date to a year and zero-based day of year.
-- Normalises the month first, then the day using @{off}. Month 0 means
-- December of the previous year; day 0 means the last day of the preceding
-- month. Returns a year and day of year, not an absolute day count.
-- @tparam number y Integer year, using astronomical numbering (including year 0).
-- @tparam number mon Integer one-based month; may be outside 1..12.
-- @tparam number day Integer one-based day of month; may be outside the month.
-- @treturn number Normalised year.
-- @treturn number Zero-based day of year, in 0..364 or 0..365 for a leap year.
-- @usage
-- local leap = require "leap"
-- local year, day = leap.from(2024, 3, 0) -- 2024, 59 (February 29)
function _M.from(y, mon, day)
  local y_, mon_ = div.mod(mon - 1, 12)
  y = y + y_
  return _M.off(y, _M.yday(y, mon_ + 1) + day - 1)
end

--- Converts an absolute day to a calendar date.
-- Absolute day 0 is January 1 of year 0, not January 1, 1970.
-- Negative days refer to dates before year 0. Inverse of @{absfrom} for
-- normalised dates.
-- @tparam number day Integer days since January 1 of year 0.
-- @treturn number Year, using astronomical numbering (including year 0).
-- @treturn number Month in 1..12.
-- @treturn number One-based day of month.
-- @usage
-- local leap = require "leap"
-- local year, month, day = leap.absdate(719528) -- 1970, 1, 1
function _M.absdate(day)
  return _M.date(0, day)
end

--- Converts a calendar date to an absolute day.
-- Normalises months and days using @{from}. Inverse of @{absdate} for
-- normalised dates. Absolute day 0 is January 1 of year 0.
-- @tparam number y Integer year, using astronomical numbering (including year 0).
-- @tparam number mon Integer one-based month; may be outside 1..12.
-- @tparam number day Integer one-based day of month; may be outside the month.
-- @treturn number Days since January 1 of year 0.
-- @usage
-- local leap = require "leap"
-- local absolute = leap.absfrom(1970, 1, 1) -- 719528
function _M.absfrom(y, mon, day)
  local y_, day_ = _M.from(y, mon, day)
  return _M.day(y_) + day_
end

return _M
