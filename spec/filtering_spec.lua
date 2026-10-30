describe("filtering", function()
  local filtering = require "filtering"

  it("collects pairs selected by the filter", function()
    local pairs = filtering.fields(function(index, value)
      return index % 2 == 1 and value ~= "skip"
    end, next, { "one", "skip", "three", "four" })

    assert.same({ [1] = "one", [3] = "three" }, pairs)
  end)

  it("returns an empty table when no pairs match", function()
    assert.same({}, filtering.fields(function()
      return false
    end, next, {}))
  end)
end)
