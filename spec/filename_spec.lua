---@diagnostic disable: duplicate-set-field -- Tests replace io.open with file doubles.
describe("filename", function()
  local filename = require "filename"
  local saved_open

  before_each(function()
    saved_open = io.open
  end)

  after_each(function()
    io.open = saved_open
  end)

  it("opens files for reading and returns read values", function()
    local opened
    local fake
    fake = {
      read = function(_, ...)
        assert.same({ "*a" }, { ... })
        return "contents", "extra"
      end,
      close = function()
        return true
      end
    }
    local original_open = io.open
    io.open = function(path, mode)
      opened = { path, mode }
      return fake
    end

    local contents, extra = filename.read("b")("example", "*a")

    io.open = original_open

    assert.same({ "example", "rb" }, opened)
    assert.equal("contents", contents)
    assert.equal("extra", extra)
  end)

  it("opens files for writing and returns write values", function()
    local opened
    local written
    local fake
    fake = {
      write = function(_, ...)
        written = { ... }
        return fake
      end,
      close = function()
        return true
      end
    }
    local original_open = io.open
    io.open = function(path, mode)
      opened = { path, mode }
      return fake
    end

    local result = filename.write("b")("example", "contents")

    io.open = original_open

    assert.same({ "example", "wb" }, opened)
    assert.same({ "contents" }, written)
    assert.equal(fake, result)
  end)

  it("returns open errors without attempting to close", function()
    local original_open = io.open
    io.open = function()
      return nil, "open failed"
    end

    local file, err = filename.read()("missing")
    local written, write_error = filename.write("")("missing", "contents")

    io.open = original_open

    assert.is_nil(file)
    assert.equal("open failed", err)
    assert.is_nil(written)
    assert.equal("open failed", write_error)
  end)

  for _, operation in ipairs { "read", "write" } do
    it("closes after a thrown " .. operation .. " error", function()
      local failure = {}
      local closed = 0
      io.open = function()
        return {
          [operation] = function()
            error(failure)
          end,
          close = function()
            closed = closed + 1
            return true
          end
        }
      end

      local ok, err = pcall(filename[operation](""), "example", "*a")

      assert.is_false(ok)
      assert.equal(failure, err)
      assert.equal(1, closed)
    end)

    it("preserves all " .. operation .. " return values", function()
      local closed = 0
      io.open = function()
        return {
          [operation] = function()
            return nil, "operation failed", nil
          end,
          close = function()
            closed = closed + 1
            return true
          end
        }
      end
      local function capture(...)
        return select("#", ...), { ... }
      end

      local count, values = capture(filename[operation]("")("example", "*a"))

      assert.equal(3, count)
      assert.is_nil(values[1])
      assert.equal("operation failed", values[2])
      assert.is_nil(values[3])
      assert.equal(1, closed)
    end)

    for _, throws in ipairs { false, true } do
      it("preserves a " .. operation .. " error when closing "
        .. (throws and "throws" or "fails"), function()
        local failure = {}
        local closed = 0
        io.open = function()
          return {
            [operation] = function()
              error(failure)
            end,
            close = function()
              closed = closed + 1
              if throws then error("close failed") end
              return nil, "close failed"
            end
          }
        end

        local ok, err = pcall(filename[operation](""), "example", "*a")

        assert.is_false(ok)
        assert.equal(failure, err)
        assert.equal(1, closed)
      end)
    end

    it("propagates a thrown close error after a successful " .. operation, function()
      local failure = {}
      io.open = function()
        return {
          [operation] = function()
            return "result"
          end,
          close = function()
            error(failure)
          end
        }
      end

      local ok, err = pcall(filename[operation](""), "example", "*a")

      assert.is_false(ok)
      assert.equal(failure, err)
    end)
  end

  it("returns close errors instead of read or write results", function()
    local original_open = io.open
    io.open = function()
      return {
        read = function()
          return "contents"
        end,
        write = function()
          return true
        end,
        close = function()
          return nil, "close failed"
        end
      }
    end

    local file, read_error = filename.read()("example", "*a")
    local written, write_error = filename.write("")("example", "contents")

    io.open = original_open

    assert.is_nil(file)
    assert.equal("close failed", read_error)
    assert.is_nil(written)
    assert.equal("close failed", write_error)
  end)
end)
