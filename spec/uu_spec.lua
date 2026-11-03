describe("uu", function()
  local uu = require "uu"

  it("generates formatted identifiers with an increasing sequence", function()
    local seq = uu.SEQ
    local first = uu.id()
    local second = uu.id()

    assert.matches("^%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d$", first)
    assert.matches("^%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d$", second)
    assert.equal(string.format("%04d", (seq + 1) % 10000), first:sub(-4))
    assert.equal(string.format("%04d", (seq + 2) % 10000), second:sub(-4))
  end)
end)
