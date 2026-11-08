describe("safely", function()
  local safely = require "safely"
  local filenames

  local function tmpfile(contents)
    local filename = os.tmpname()
    table.insert(filenames, filename)
    local file = assert(io.open(filename, "w"))
    file:write(contents)
    file:close()
    return filename
  end

  before_each(function()
    filenames = {}
  end)

  after_each(function()
    for _, filename in ipairs(filenames) do
      os.remove(filename)
    end
  end)

  describe("dofile", function()
    it("executes a chunk within a new empty environment", function()
      local filename = tmpfile [[answer = 42]]

      local env = safely.dofile(filename)

      assert.same({ answer = 42 }, env)
    end)

    it("executes a chunk within a given environment", function()
      local filename = tmpfile [[doubled = seed * 2]]
      local given = { seed = 21 }

      local env = safely.dofile(filename, given)

      assert.equal(given, env)
      assert.equal(42, env.doubled)
    end)

    it("isolates the chunk from globals", function()
      local filename = tmpfile [[leaked = true]]

      safely.dofile(filename)

      assert.is_nil(_G.leaked)
    end)

    it("returns the environment when the file is missing", function()
      local given = { untouched = true }

      local env = safely.dofile("no/such/file.lua", given)

      assert.equal(given, env)
      assert.same({ untouched = true }, env)
    end)

    it("creates an empty environment when the file is missing", function()
      assert.same({}, safely.dofile("no/such/file.lua"))
    end)

    it("returns the environment despite syntax errors", function()
      local filename = tmpfile [[this is not lua (]]

      assert.same({}, safely.dofile(filename))
    end)

    it("keeps assignments made before a runtime error", function()
      local filename = tmpfile [[
        before = "kept"
        error("boom")
        after = "lost"
      ]]

      local env = safely.dofile(filename)

      assert.equal("kept", env.before)
      assert.is_nil(env.after)
    end)

    it("ignores calls to unavailable globals", function()
      local filename = tmpfile [[
        before = true
        print("unavailable in an empty environment")
      ]]

      local env = safely.dofile(filename)

      assert.is_true(env.before)
    end)
  end)
end)
