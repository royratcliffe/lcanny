describe("interleaving", function()
  local interleaving = require "interleaving"

  it("returns the next index and pair", function()
    local index, first, second = interleaving.inext({ "a", 1 }, 0)

    assert.equal(2, index)
    assert.equal("a", first)
    assert.equal(1, second)
  end)

  it("continues iterating when the first value is false", function()
    local index, first, second = interleaving.inext({ false, "value" }, 0)

    assert.equal(2, index)
    assert.is_false(first)
    assert.equal("value", second)
  end)

  it("iterates pairs including an incomplete final pair", function()
    local expected = {
      { index = 2, first = "a", second = 1 },
      { index = 4, first = "b", second = 2 },
      { index = 6, first = "c" },
    }
    local count = 0

    for index, first, second in interleaving.ipairs({ "a", 1, "b", 2, "c" }) do
      count = count + 1
      assert.equal(expected[count].index, index)
      assert.equal(expected[count].first, first)
      assert.equal(expected[count].second, second)
    end

    assert.equal(#expected, count)
  end)

  it("stops when there are no more pairs", function()
    local index, first, second = interleaving.inext({ "a", 1 }, 2)

    assert.is_nil(index)
    assert.is_nil(first)
    assert.is_nil(second)
  end)

  it("iterates an empty array zero times", function()
    local count = 0

    for _ in interleaving.ipairs({}) do
      count = count + 1
    end

    assert.equal(0, count)
  end)
end)
