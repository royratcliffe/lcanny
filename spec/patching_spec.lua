describe("patching", function()
  local patching = require "patching"

  it("returns nil when tables are equal", function()
    assert.is_nil(patching.diff({ a = 1 }, { a = 1 }))
    assert.is_nil(patching.diff({}, {}))
  end)

  it("creates a patch that transforms the left table into the right table", function()
    local left = {
      unchanged = "same",
      changed = "old",
      nested = { kept = 1, restored = true },
      only_left = 10,
    }
    local right = {
      unchanged = "same",
      changed = "new",
      nested = { kept = 1, extra = true },
      only_right = 20,
    }
    local patch = patching.diff(left, right)

    assert.same({
      patched = {
        nested = {
          changed = { extra = true },
          removed = { restored = true },
        },
      },
      changed = { changed = "new", only_right = 20 },
      removed = { only_left = 10 },
    }, patch)

    patching.apply(left, patch)
    assert.same(right, left)
  end)

  it("creates missing nested tables while applying nested patches", function()
    local value = {}

    patching.apply(value, {
      patched = { nested = { changed = { answer = 42 } } },
    })

    assert.same({ nested = { answer = 42 } }, value)
  end)

  it("does nothing when applying a nil patch", function()
    local value = { answer = 42 }

    patching.apply(value, nil)

    assert.same({ answer = 42 }, value)
  end)
end)
