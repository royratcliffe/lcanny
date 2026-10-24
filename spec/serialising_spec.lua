describe("serialising", function()
  local serialising = require "serialising"

  it("serialises primitive values and unsupported types", function()
    assert.equal("42", serialising.value(42))
    assert.equal("false", serialising.value(false))
    assert.equal('"hello"', serialising.value("hello"))
    assert.equal("nil", serialising.value(nil))
    assert.equal("nil", serialising.value(function() end))
  end)

  it("serialises indexed primitives with indentation", function()
    assert.equal("\tanswer = 42", serialising.value(42, "answer", "\t"))
    assert.equal('flag = true', serialising.value(true, "flag"))
  end)

  it("serialises arrays", function()
    assert.equal(
      '{\n\t1,\n\t"two",\n\tfalse\n}',
      serialising.value({ 1, "two", false })
    )
  end)

  it("serialises sorted numeric and string keys", function()
    assert.equal(
      '{\n\t[1] = "one",\n\t[2] = "two",\n\talpha = 1,\n\tbeta = 2\n}',
      serialising.value({ [2] = "two", [1] = "one", beta = 2, alpha = 1 })
    )
  end)

  it("quotes non-identifier string keys and omits unsupported key types", function()
    assert.equal(
      '{\n\t["not-valid"] = "value"\n}',
      serialising.value({ ["not-valid"] = "value", [true] = "ignored" })
    )
  end)

  it("serialises nested tables with custom indentation and offset", function()
    assert.equal(
      'root = {\n  child = {\n    7\n  }\n}',
      serialising.value({ child = { 7 } }, "root", "", "  ")
    )
  end)

  it("serialises an empty table", function()
    assert.equal("{}", serialising.value({}))
  end)
end)
