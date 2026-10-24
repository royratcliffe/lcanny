describe("recursing", function()
  local recursed = require "recursing"

  it("copy by unpacking works", function()
    assert.same({ 1, 2, 3 }, { unpack { 1, 2, 3 } })
  end)

  it("works", function()
    local recursing = recursed.leavesandbranches {
      a = {
        b = {},
        c = 123
      }
    }
    assert.same({ "a" }, recursing())
    assert.same({ { "a", "c" }, 123, "number" }, { recursing() })
    assert.same({ "a", "b" }, recursing())
    assert.is_nil(recursing())
  end)

  it("leavesandbranches", function()
    local results = {}
    local t = { s = "" }
    t.t = t
    for subindices, value in recursed.leavesandbranches { a = 1, t = t } do
      if type(value) ~= "table" then
        table.insert(results, { subindices, value })
      end
    end
    local function result()
      return table.remove(results, 1)
    end
    assert.same({ { "a" }, 1 }, result())
    assert.same({ { "t", "s" }, "" }, result())
    assert.is_nil(result())
  end)

  it("leaves", function()
    local recursing = recursed.leaves {
      x = {
        y = 123
      }
    }
    assert.same({ { "x", "y" }, 123, "number" }, { recursing() })
    assert.is_nil(recursing())
  end)

  it("iterates branches only", function()
    local branches = {}
    for indices, value in recursed.branches({ a = { b = {} }, c = 1 }) do
      table.insert(branches, { indices, value })
    end

    assert.equal(2, #branches)
    local seen = {}
    for _, branch in ipairs(branches) do
      if branch[1][1] == "a" and #branch[1] == 1 then
        seen.a = branch[2]
      elseif branch[1][1] == "a" and branch[1][2] == "b" then
        seen.b = branch[2]
      end
    end
    assert.same({ b = {} }, seen.a)
    assert.same({}, seen.b)
  end)

  it("looks up a value by sub-indices", function()
    local root = { a = { b = 42 } }
    local parent, index, value = recursed.sub(root, "a", "b")

    assert.equal(root.a, parent)
    assert.equal("b", index)
    assert.equal(42, value)
  end)

  it("returns the root when no sub-indices are provided", function()
    local root = {}
    local parent, index, value = recursed.sub(root)

    assert.is_nil(parent)
    assert.is_nil(index)
    assert.equal(root, value)
  end)

  it("stops looking up when an intermediate value is not a table", function()
    assert.is_nil(recursed.sub({ a = 1 }, "a", "b"))
  end)

  it("rejects non-table roots when iterating", function()
    assert.has_error(function()
      recursed.leavesandbranches("not a table")
    end)
  end)
end)
