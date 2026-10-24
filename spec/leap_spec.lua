describe("leap", function()
  local leap = require "leap"

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
end)
