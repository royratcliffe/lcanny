require "busted.runner" {}

describe("co", function()
  local co = require "co"

  it("creates an empty thread list", function()
    assert.same({}, co())
  end)

  it("runs and removes a completed thread", function()
    local received
    local threads = co(function(value)
      received = value
    end, "done")

    assert.equal("done", received)
    assert.same({}, threads)
  end)

  it("removes a thread after it yields and completes", function()
    local received
    local threads = co(function(value)
      coroutine.yield()
      received = value
    end, "resumed")

    assert.equal("resumed", received)
    assert.equal(1, #threads)

    threads()

    assert.same({}, threads)
  end)

  it("logs errors raised when starting a thread", function()
    local savedlog = rawget(_G, "log")
    local logged
    _G.log = {
      ERROR = "error",
      write = function(...)
        logged = { ... }
      end
    }

    local threads = co(function()
      error("start failed")
    end)

    _G.log = savedlog

    assert.same({}, threads)
    assert.equal("on", logged[1])
    assert.equal("error", logged[2])
    assert.matches("start failed", logged[3])
  end)

  it("logs errors raised when resuming a thread", function()
    local previous_log = rawget(_G, "log")
    local logged
    _G.log = {
      ERROR = "error",
      write = function(...)
        logged = { ... }
      end
    }

    local threads = co(function()
      coroutine.yield()
      error("resume failed")
    end)

    _G.log = previous_log

    assert.equal("on", logged[1])
    assert.equal("error", logged[2])
    assert.matches("resume failed", logged[3])

    threads()

    assert.same({}, threads)
  end)

  it("rejects a non-function thread", function()
    assert.has_error(function()
      co(42)
    end)
  end)
end)
