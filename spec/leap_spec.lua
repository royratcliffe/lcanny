describe("leap", function()
  local leap = require "leap"
  local monthdays = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }

  local function isleap(year)
    if year % 400 == 0 then return true end
    if year % 100 == 0 then return false end
    return year % 4 == 0
  end

  local function daysinmonth(year, month)
    return monthdays[month] + (month == 2 and isleap(year) and 1 or 0)
  end

  local function daysinyear(year)
    return isleap(year) and 366 or 365
  end

  local function normalise(year, day)
    while day < 0 do
      year = year - 1
      day = day + daysinyear(year)
    end
    while day >= daysinyear(year) do
      day = day - daysinyear(year)
      year = year + 1
    end
    return year, day
  end

  it("year", function()
    assert.truthy(leap.year(0))
  end)

  it("day", function()
    assert.truthy(leap.year(0))
    assert.equal(366, leap.day(1))
    assert.equal(leap.MCM, leap.day(1900))
    assert.same({ 0, 0 }, { leap.off(0, leap.day(0)) })
    assert.same({ 1, 0 }, { leap.off(0, leap.day(1)) })
    assert.same({ 9, 0 }, { leap.off(0, leap.day(9)) })
    assert.same({ 1900, 0 }, { leap.off(0, leap.day(1900)) })
    assert.same({ 2900, 0 }, { leap.off(0, leap.day(2900)) })
    assert.equal(25567, leap.day(1970) - leap.day(1900))
  end)

  it("thru", function()
    assert.equal(1, leap.thru(4))
    assert.equal(24, leap.thru(100))
    assert.equal(97, leap.thru(400))
    assert.equal(693960, 1900 * 365 + leap.thru(1900))
  end)

  it("off", function()
    assert.same({ 0, 365 }, { leap.off(1, -1) })
    assert.same({ 1, 0 }, { leap.off(1, 0) })
    assert.same({ 4, 365 }, { leap.off(5, -1) })
    assert.same({ 5, 0 }, { leap.off(4, 366) })
    assert.same({ 2024, 365 }, { leap.off(2024, 365) })
    assert.same({ 2025, 0 }, { leap.off(2024, 366) })
    assert.same({ 1902, 270 }, { leap.off(1900, 1000) })
    assert.same({ 1900, 0 }, { leap.off(0, leap.MCM) })
    assert.same({ 1970, 0 }, { leap.off(0, leap.day(1970)) })

    -- There are 10 years between 1960 and 1970.
    assert.same({ 10, 0 }, { leap.off(1970, -leap.day(1960)) })

    -- The following makes little sense.
    assert.same({ 24, 365 }, { leap.off(1970, -leap.day(1945)) })
  end)

  it("date", function()
    assert.same({ 1902, 9, 28 }, { leap.date(1902, 270) })
    assert.same({ 1, 1, 1 }, { leap.date(1, 0) })
    assert.same({ 2, 1, 1 }, { leap.date(1, 365) })
  end)

  it("from", function()
    assert.same({ 2024, 1, 1 }, { leap.date(leap.from(2024, 1, 1)) })
    assert.same({ 2023, 12, 1 }, { leap.date(leap.from(2024, 0, 1)) })
    assert.same({ 2023, 11, 30 }, { leap.date(leap.from(2024, 0, 0)) })
  end)

  it("absdate", function()
    assert.same({ 0, 1, 1 }, { leap.absdate(0) })
    assert.same({ 1970, 1, 1 }, { leap.absdate(leap.absfrom(1970, 1, 1)) })
    assert.same({ 1970, 2, 1 }, { leap.absdate(leap.absfrom(1970, 1, 31) + 1) })
  end)

  it("absfrom", function()
    assert.equal(0, leap.absfrom(0, 1, 1))
  end)

  it("exports the common-year month lengths and offsets", function()
    assert.same(monthdays, leap.MDAY)
    local offset = 0
    for month = 1, 12 do
      assert.equal(offset, leap.YDAY[month])
      offset = offset + monthdays[month]
    end
    assert.equal(693961, leap.MCM)
  end)

  it("classifies every year across negative and positive Gregorian cycles", function()
    local leapdays = -195
    local absolute = -292194
    for year = -800, 2400 do
      local expected = isleap(year)
      assert.equal(expected, leap.year(year), "year " .. year)
      assert.equal(expected and 1 or 0, leap.add(year), "add " .. year)
      assert.equal(leapdays, leap.thru(year - 1), "thru " .. (year - 1))
      assert.equal(absolute, leap.day(year), "day " .. year)
      if expected then leapdays = leapdays + 1 end
      assert.equal(leapdays, leap.thru(year), "thru " .. year)
      absolute = absolute + daysinyear(year)
    end
  end)

  it("converts every day of a complete 400-year Gregorian cycle", function()
    local absolute = 0
    for year = 0, 399 do
      local yday = 0
      for month = 1, 12 do
        local mday = daysinmonth(year, month)
        assert.equal(mday, leap.mday(year, month))
        assert.equal(yday, leap.yday(year, month))
        for day = 1, mday do
          assert.same({ year, month, day }, { leap.date(year, yday) })
          assert.same({ year, yday }, { leap.from(year, month, day) })
          assert.same({ year, yday }, { leap.off(0, absolute) })
          assert.same({ year, month, day }, { leap.absdate(absolute) })
          assert.equal(absolute, leap.absfrom(year, month, day))
          yday, absolute = yday + 1, absolute + 1
        end
      end
      assert.equal(daysinyear(year), yday)
    end
    assert.equal(146097, absolute)
  end)

  it("converts every negative-year month boundary across a Gregorian cycle", function()
    local absolute = -146097
    for year = -400, -1 do
      local yday = 0
      for month = 1, 12 do
        local mday = daysinmonth(year, month)
        assert.equal(mday, leap.mday(year, month))
        assert.equal(yday, leap.yday(year, month))
        for _, day in ipairs({ 1, mday }) do
          local offset = day - 1
          assert.same({ year, month, day }, { leap.date(year, yday + offset) })
          assert.same({ year, yday + offset }, { leap.from(year, month, day) })
          assert.same({ year, month, day }, { leap.absdate(absolute + offset) })
          assert.equal(absolute + offset, leap.absfrom(year, month, day))
        end
        yday, absolute = yday + mday, absolute + mday
      end
    end
    assert.equal(0, absolute)
  end)

  it("normalises day offsets around every year boundary in two cycles", function()
    for year = -400, 399 do
      local yday = daysinyear(year)
      local offsets = {
        -146098, -146097, -146096, -1000, -367, -366, -365, -1,
        0, 1, yday - 1, yday, yday + 1,
        1000, 146096, 146097, 146098,
      }
      for _, offset in ipairs(offsets) do
        assert.same({ normalise(year, offset) }, { leap.off(year, offset) },
          "year " .. year .. ", offset " .. offset)
      end
    end
  end)

  it("normalises overflowing months and days across century boundaries", function()
    for _, year in ipairs({ -400, -100, -1, 0, 1, 4, 100, 400, 1900, 2000, 2100 }) do
      for month = -24, 36 do
        local expectedyear, expectedmonth = year, month
        while expectedmonth < 1 do
          expectedyear, expectedmonth = expectedyear - 1, expectedmonth + 12
        end
        while expectedmonth > 12 do
          expectedyear, expectedmonth = expectedyear + 1, expectedmonth - 12
        end
        local yday = 0 -- day of year for the first day of the expected month
        for previousmonth = 1, expectedmonth - 1 do
          yday = yday + daysinmonth(expectedyear, previousmonth)
        end
        local mday = daysinmonth(expectedyear, expectedmonth)
        for _, day in ipairs({ -367, -31, -1, 0, 1, mday, mday + 1, 367 }) do
          local y, d = normalise(expectedyear, yday + day - 1)
          assert.same({ y, d }, { leap.from(year, month, day) },
            "year " .. year .. ", month " .. month .. ", day " .. day)
          local mon = 1
          while d >= daysinmonth(y, mon) do
            d, mon = d - daysinmonth(y, mon), mon + 1
          end
          assert.same({ y, mon, d + 1 }, { leap.date(leap.from(year, month, day)) })
        end
      end
    end
  end)

  it("anchors absolute dates at year zero rather than the Unix epoch", function()
    local cases = {
      { -400, 1,  1,  -146097 },
      { -1,   12, 31, -1 },
      { 0,    1,  1,  0 },
      { 0,    2,  29, 59 },
      { 1,    1,  1,  366 },
      { 400,  1,  1,  146097 },
      { 1900, 1,  1,  693961 },
      { 1970, 1,  1,  719528 },
      { 2000, 1,  1,  730485 },
    }
    for _, case in ipairs(cases) do
      local year, month, day, absolute = case[1], case[2], case[3], case[4]
      assert.equal(absolute, leap.absfrom(year, month, day))
      assert.same({ year, month, day }, { leap.absdate(absolute) })
    end
  end)
end)
