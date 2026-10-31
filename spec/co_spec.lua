---@diagnostic disable: duplicate-set-field -- Tests replace the logging callback.
require "busted.runner" {}

describe("co", function()
  local co = require "co"
  local saved_log
  local saved_stderr

  before_each(function()
    saved_log = co.log
    saved_stderr = io.stderr
  end)

  after_each(function()
    co.log = saved_log
    io.stderr = saved_stderr
  end)

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
    local logged
    co.log = function(message)
      logged = message
    end

    local threads = co(function()
      error("start failed")
    end)

    assert.same({}, threads)
    assert.matches("start failed", logged)
  end)

  it("logs errors raised when resuming a thread", function()
    local logged
    co.log = function(message)
      logged = message
    end

    local threads = co(function()
      coroutine.yield()
      error("resume failed")
    end)

    assert.matches("resume failed", logged)

    threads()

    assert.same({}, threads)
  end)

  it("writes errors to stderr by default", function()
    local written
    io.stderr = {
      write = function(_, ...)
        written = { ... }
        return true
      end
    }

    assert.same({}, co(function()
      error("default logger")
    end))
    assert.matches("default logger", written[1])
    assert.equal("\n", written[2])
  end)

  it("uses a replaced logger for an existing thread list", function()
    local threads = co()
    local logged
    co.log = function(message)
      logged = message
    end

    local failure = setmetatable({}, {
      __tostring = function()
        return "error object"
      end
    })
    threads(function()
      error(failure)
    end)

    assert.equal("error object", logged)
    assert.same({}, threads)
  end)

  it("propagates failures from the logger", function()
    co.log = function()
      error("logger failed")
    end

    assert.has_error(function()
      co(function()
        error("thread failed")
      end)
    end, "logger failed")
  end)

  it("propagates stderr write errors", function()
    io.stderr = {
      write = function()
        return nil, "write failed"
      end
    }

    assert.has_error(function()
      co.log("thread failed")
    end, "write failed")
  end)

  it("rejects a non-function thread", function()
    assert.has_error(function()
      co(42)
    end)
  end)
end)
