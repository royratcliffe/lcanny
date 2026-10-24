describe("collecting", function()
  local collecting = require "collecting"

  --- Returns the key and value for each item in the array.
  -- @tparam tab items Array of items to iterate over.
  -- @treturn int Key for the current item.
  -- @treturn any Value for the current item.
  local function pairiterator(items)
    local index = 0
    return function()
      index = index + 1
      if items[index] ~= nil then
        return index, items[index]
      end
    end, nil, 0
  end

  --- Returns the key, index, and value for each item in the array.
  -- Indexed pair iterator returns a key, an index, and a value. The key
  -- is ignored, and the index is multiplied by 10.
  -- @tparam tab items Array of items to iterate over.
  -- @treturn string Key for the current item (ignored).
  -- @treturn int Index for the current item (multiplied by 10).
  -- @treturn any Value for the current item.
  local function indexedpairiterator(items)
    local index = 0
    return function()
      index = index + 1
      if items[index] ~= nil then
        return "ignored", index * 10, items[index]
      end
    end, nil, 0
  end

  it("collects the first value from each iteration", function()
    assert.same({ 1, 2, 3 }, collecting.values(pairiterator({ "a", "b", "c" })))
  end)

  it("collects the second value from each iteration", function()
    assert.same({ "a", "b", "c" }, collecting.ivalues(pairiterator({ "a", "b", "c" })))
  end)

  it("collects iterator pairs into a table", function()
    assert.same({ "a", "b", "c" }, collecting.fields(pairiterator({ "a", "b", "c" })))
  end)

  it("collects indexed iterator pairs into a table", function()
    assert.same(
      { [10] = "a", [20] = "b", [30] = "c" },
      collecting.ifields(indexedpairiterator({ "a", "b", "c" }))
    )
  end)

  it("returns empty collections for an empty iterator", function()
    local function empty()
      return nil
    end

    assert.same({}, collecting.values(empty))
    assert.same({}, collecting.ivalues(empty))
    assert.same({}, collecting.fields(empty))
    assert.same({}, collecting.ifields(empty))
  end)
end)
