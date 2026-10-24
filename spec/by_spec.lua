describe("by", function()
  local by = require "by"

  it("groups values by a key function", function()
    local groups = by.group(function(value)
      return value.kind
    end, {
      { kind = "fruit", name = "apple" },
      { kind = "vegetable", name = "carrot" },
      { kind = "fruit", name = "pear" },
    })

    assert.same({
      fruit = {
        { kind = "fruit", name = "apple" },
        { kind = "fruit", name = "pear" },
      },
      vegetable = {
        { kind = "vegetable", name = "carrot" },
      },
    }, groups)
  end)

  it("returns no groups for an empty array", function()
    assert.same({}, by.group(function(value)
      return value
    end, {}))
  end)
end)
