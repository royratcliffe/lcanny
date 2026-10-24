describe("indexing", function()
  local indexing = require "indexing"

  it("returns existing values without replacing them", function()
    local values = { present = false }

    assert.is_false(indexing.of(values, "present", "default"))
    assert.is_nil(values.missing)
  end)

  it("stores a constant default for missing values", function()
    local values = {}

    assert.equal("default", indexing.of(values, "missing", "default"))
    assert.equal("default", values.missing)
  end)

  it("calls a default function with the missing index", function()
    local values = {}
    local calls = 0

    local result = indexing.of(values, "missing", function(index)
      calls = calls + 1
      assert.equal("missing", index)
      return {}
    end)

    assert.equal(1, calls)
    assert.equal(result, values.missing)
  end)

  it("creates and returns nested indices", function()
    local values = {}
    local result = indexing.findof(values, "a", "b")

    assert.equal(result, values.a.b)
    assert.same({}, result)
  end)

  it("returns the root when no indices are given", function()
    local values = {}

    assert.equal(values, indexing.findof(values))
  end)

  it("returns an existing terminal value", function()
    local values = { a = { b = 42 } }

    assert.equal(42, indexing.findof(values, "a", "b"))
  end)

  it("errors when an intermediate value is not a table", function()
    assert.has_error(function()
      indexing.findof({ a = 1 }, "a", "b")
    end)
  end)
end)
