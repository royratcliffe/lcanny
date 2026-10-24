require "busted.runner" {}

describe("strbuf", function()
  local strbuf = require "strbuf"

  it("works", function()
    local buf = strbuf.new()
    assert.equal("", tostring(buf))
    assert.equal("", -buf)
    buf(1)
    buf("a")
    assert.equal("1a", -buf)
    assert.equal("1a", "" / buf)
    assert.equal("1a", nil / buf)
    assert.equal(2, #buf)
  end)

  it("supports custom separators and direct division", function()
    local newbuf = strbuf.factory(" ")
    local buf = newbuf("a", "b", "c")

    assert.equal("a b c", tostring(buf))
    assert.equal("a:b:c", buf / ":")
  end)
end)
