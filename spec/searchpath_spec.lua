describe("searchpath", function()
  local searchpath = require "searchpath"

  describe("mergewith", function()
    it("returns the path unchanged when merging nothing", function()
      assert.equal("a;b", searchpath.mergewith("a;b"))
    end)

    it("appends new values to the path", function()
      assert.equal("a;b;c", searchpath.mergewith("a;b", "c"))
    end)

    it("appends multiple values in order", function()
      assert.equal("a;b;c;d", searchpath.mergewith("a", "b", "c", "d"))
    end)

    it("ignores values already present in the path", function()
      assert.equal("a;b", searchpath.mergewith("a;b", "a", "b"))
    end)

    it("ignores repeated merging values", function()
      assert.equal("a;b", searchpath.mergewith("a", "b", "b", "b"))
    end)

    it("removes duplicates already present in the path", function()
      assert.equal("a;b", searchpath.mergewith("a;b;a;b;a"))
    end)

    it("preserves first-seen order when removing duplicates", function()
      assert.equal("b;a;c", searchpath.mergewith("b;a;b", "c", "a"))
    end)

    it("merges into an empty path", function()
      assert.equal("a;b", searchpath.mergewith("", "a", "b"))
    end)

    it("returns an empty string for an empty path and no values", function()
      assert.equal("", searchpath.mergewith(""))
    end)

    it("discards empty path segments", function()
      assert.equal("a;b", searchpath.mergewith(";a;;b;"))
    end)

    it("treats differing segments as distinct", function()
      assert.equal("a;A;a/?.lua", searchpath.mergewith("a;A", "a/?.lua"))
    end)

    it("merges typical Lua search path templates", function()
      assert.equal(
        "./?.lua;/usr/share/lua/5.4/?.lua;./src/?.lua",
        searchpath.mergewith(
          "./?.lua;/usr/share/lua/5.4/?.lua",
          "./src/?.lua",
          "./?.lua"
        )
      )
    end)
  end)
end)
