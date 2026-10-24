--- Leap year calculations.
-- This module provides functions for determining leap years and performing
-- date calculations that account for leap years in the Gregorian calendar.
-- It includes functions to check if a year is a leap year, calculate the number
-- of leap days up to a given year, and convert between different date formats.
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
-- @param y The year to check.
function _M.year(y)
  return y % 4 == 0 and (y % 100 ~= 0 or y % 400 == 0)
end

--- Adds one for a leap year otherwise zero.
-- Answers 1 if the year is a leap year, otherwise answers 0. This is
-- the same result as is_leap() except that the result is an explicit integer; 1
-- for leap years, 0 for non-leap years.
-- @param y The year to check.
-- @return 1 if the year is a leap year, otherwise 0.
function _M.add(y)
  return _M.year(y) and 1 or 0
end

--- Leaped days completed up to but not including the first day of the given year.
-- Counts the number of leap days that have occurred from year 0 up to but not
-- including the first day of the given year. This is calculated as the number
-- of years divisible by 4, minus those divisible by 100, plus those divisible
-- by 400. This accounts for the rules of leap years in the Gregorian calendar.
-- @param y The year to check.
-- @treturn number The number of leap days completed up to but not including the
-- first day of the given year.
function _M.thru(y)
  return div.mod(y, 4) - div.mod(y, 100) + div.mod(y, 400)
end

-- Counts the number of leaped days completed up to but not including the first
-- day of the given year.
function _M.day(y)
  return y * 365 + _M.thru(y - 1) + 1
end

--- Offsets year and day of year.
-- Year and day of year from year and day of year.
-- Adjust the day so that it sits in-between 0 and 365 or 366, inclusively.
--
-- The day is adjusted to be within the range of 0 to 365 (or
-- 366) inclusively, and the year is adjusted accordingly.
-- This function ensures that the day of the year does not exceed the number of
-- days in the year, accounting for leap years.
-- If the day is negative or exceeds the number of days in the year, it adjusts
-- the year and day accordingly.
-- The day is adjusted to be 0-based, meaning it starts from 0 for the
-- first day of the year.
-- The year is adjusted to account for the number of days in the year, which can
-- be either 365 or 366 depending on whether it is a leap year.
-- @param y The year.
-- @param day The day of the year, starting from 0.
-- @return The year adjusted to account for the number of days in the year.
-- @return The adjusted day of the year, starting from 0 for the first day.
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

--- Day of month from year and month.
-- Returns the number of days in the month for the given year and month.
-- @param y The year.
-- @param mon The month, starting from 1 for January.
-- @return The number of days in the month, accounting for leap years in
-- February.
function _M.mday(y, mon)
  return _M.MDAY[mon] + (mon == 2 and _M.add(y) or 0)
end

--- Day of year from year and month.
-- Returns the day of the year for the given year and month.
-- The day of the year is calculated by summing the days in the months up to
-- the given month, and adding an extra day if the month is after February in a
-- leap year.
-- @param y The year.
-- @param mon The month, starting from 1 for January.
-- @return The day of the year, starting from 0 for first of January.
function _M.yday(y, mon)
  return _M.YDAY[mon] + (mon > 2 and _M.add(y) or 0)
end

--- Date from year and day of year.
-- Adjust the day so that it sits in-between 1 and 365 (or 366) inclusively.
-- Returns the year, month, and day of the month for the given year and day of
-- year. The day of the month is adjusted to be 1-based, meaning it starts from 1
-- for the first day of the month.
-- @param y The year.
-- @param day The day of the year, starting from 0 for first of January.
-- @return The year.
-- @return The month, starting from 1 for January.
-- @return The day of the month, starting from 1 for the first day of the month.
function _M.date(y, day)
  y, day = _M.off(y, day)
  for mon = 1, 12 do
    local mday = _M.mday(y, mon)
    if day < mday then return y, mon, day + 1 end
    day = day - mday
  end
end

--- Day from year, month and day of month.
-- Adjust the month so that it sits in-between 1 and 12 inclusively. The month
-- offsets the year.
-- Returns the absolute date from the given year, month, and day of month.
-- The absolute date is calculated as the number of days since the epoch
-- (January 1, 1970).
-- @param y The year.
-- @param mon The month, starting from 1 for January.
-- @param day The day of the month, starting from 1 for the first day of the month.
-- @return The absolute date as the number of days since the epoch.
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

--- Absolute date from year, month, and day of month.
-- Returns the absolute date from the given year, month, and day of month. The
-- absolute date is calculated as the number of days since January 1 of year 0.
-- @param y The year.
-- @param mon The month, starting from 1 for January.
-- @param day The day of the month, starting from 1 for the first day of the month.
-- @return The absolute date as the number of days since the epoch.
function _M.absfrom(y, mon, day)
  local y_, day_ = _M.from(y, mon, day)
  return _M.day(y_) + day_
end

return _M
