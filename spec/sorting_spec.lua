describe("sorting", function()
  local sorting = require "sorting"

  local function entries(...)
    local result = {}
    for ordering, key, value in ... do
      result[#result + 1] = { ordering, key, value }
    end
    return result
  end

  it("sorts sparse numeric keys and returns their positions and values", function()
    local indexed = {
      [-3] = "negative",
      [0] = false,
      [4] = "four",
      [9] = "nine",
    }

    assert.same({
      { 1, -3, "negative" },
      { 2, 0, false },
      { 3, 4, "four" },
      { 4, 9, "nine" },
    }, entries(sorting.ipairs(indexed)))
  end)

  it("sorts string keys in ascending order by default", function()
    local indexed = { zebra = 1, apple = 3, mango = 2 }

    assert.same({
      { 1, "apple", 3 },
      { 2, "mango", 2 },
      { 3, "zebra", 1 },
    }, entries(sorting.ipairs(indexed)))
  end)

  it("uses the supplied comparator to order keys", function()
    local indexed = { [1] = "six", [3] = "two", [5] = "one" }

    assert.same({
      { 1, 5, "one" },
      { 2, 3, "two" },
      { 3, 1, "six" },
    }, entries(sorting.ipairs(indexed, function(left, right)
      return left > right
    end)))
  end)

  it("supports mixed key types when the comparator can order them", function()
    local indexed = { [2] = "two", ["10"] = "ten", [1] = "one" }

    assert.same({
      { 1, 1, "one" },
      { 2, 2, "two" },
      { 3, "10", "ten" },
    }, entries(sorting.ipairs(indexed, function(left, right)
      return tonumber(left) < tonumber(right)
    end)))
  end)

  it("iterates boolean keys using a comparator", function()
    local indexed = { [false] = "off", [true] = "on" }

    assert.same({
      { 1, false, "off" },
      { 2, true, "on" },
    }, entries(sorting.ipairs(indexed, function(left, right)
      return left == false and right == true
    end)))
  end)

  it("iterates a single false key without a comparator", function()
    assert.same({
      { 1, false, "value" },
    }, entries(sorting.ipairs({ [false] = "value" })))
  end)

  it("returns an iterator, state and initial control index", function()
    local iterator, state, ordering = sorting.ipairs({ b = 2, a = 1 })

    assert.equal("function", type(iterator))
    assert.equal("table", type(state))
    assert.equal(0, ordering)

    local key, value
    ordering, key, value = iterator(state, ordering)
    assert.same({ 1, "a", 1 }, { ordering, key, value })
    ordering, key, value = iterator(state, ordering)
    assert.same({ 2, "b", 2 }, { ordering, key, value })
    ordering, key, value = iterator(state, ordering)
    assert.is_nil(ordering)
    assert.is_nil(key)
    assert.is_nil(value)
  end)

  it("snapshots keys while reading current values from the original table", function()
    local indexed = { a = "original", c = "removed" }
    local iterator, state, ordering = sorting.ipairs(indexed)
    indexed.a = false
    indexed.b = "new"
    indexed.c = nil

    assert.same({
      { 1, "a", false },
      { 2, "c" },
    }, entries(iterator, state, ordering))
  end)

  it("immediately terminates when the table is empty", function()
    local iterator, state, ordering = sorting.ipairs({})
    local next_ordering, key, value = iterator(state, ordering)

    assert.is_nil(next_ordering)
    assert.is_nil(key)
    assert.is_nil(value)
    assert.same({}, entries(iterator, state, ordering))
  end)

  it("propagates comparator errors", function()
    assert.has_error(function()
      sorting.ipairs({ a = 1, b = 2 }, function()
        error("comparison failed", 0)
      end)
    end, "comparison failed")
  end)

  it("rejects keys that cannot be compared by default", function()
    assert.has_error(function()
      sorting.ipairs({ [1] = "one", two = 2 })
    end)
  end)

  it("rejects a non-table input", function()
    assert.has_error(function()
      sorting.ipairs(nil)
    end)
  end)
end)
