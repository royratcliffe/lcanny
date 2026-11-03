describe("escape", function()
  local escape = require "escape"

  it("escapes reserved characters as lowercase hexadecimal bytes", function()
    local escaped, count = escape.en("a b/c%")

    assert.equal("a%20b%2fc%25", escaped)
    assert.equal(3, count)
  end)

  it("leaves alphanumeric characters and underscores unchanged", function()
    local escaped, count = escape.en("AZaz09_")

    assert.equal("AZaz09_", escaped)
    assert.equal(0, count)
  end)

  it("uses a supplied Lua pattern", function()
    local escaped, count = escape.en("a-b_c", "[_-]")

    assert.equal("a%2db%5fc", escaped)
    assert.equal(2, count)
  end)

  it("decodes upper- and lowercase hexadecimal sequences", function()
    assert.equal("A//", escape.un("%41%2f%2F"))
  end)

  it("preserves incomplete and invalid escape sequences", function()
    assert.equal("%GG %2 %", escape.un("%GG %2 %"))
  end)
end)
