describe("filename", function()
  local filename = require "filename"

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
