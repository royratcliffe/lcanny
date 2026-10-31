describe("so", function()
  local so = require "so"

  it("sends once with default bounds", function()
    local arguments
    local send = so.sending({
      send = function(_, ...)
        arguments = { ... }
        return 4
      end
    }, function()
      error("timeout callback should not run")
    end)

    assert.equal(4, send("data"))
    assert.same({ "data", 1 }, arguments)
    assert.is_nil(arguments[3])
  end)

  it("retries timed-out sends from the last partial byte", function()
    local attempts = {}
    local timeouts = 0
    local send = so.sending({
      send = function(_, ...)
        table.insert(attempts, { ... })
        if #attempts == 1 then
          return nil, "timeout", 3
        end
        return 8
      end
    }, function()
      timeouts = timeouts + 1
    end)

    assert.equal(8, send("data", 2, 9))
    assert.equal(1, timeouts)
    assert.same({
      { "data", 2, 9 },
      { "data", 4, 9 }
    }, attempts)
  end)

  it("returns non-timeout send errors", function()
    local send = so.sending({
      send = function()
        return nil, "closed"
      end
    }, function()
      error("timeout callback should not run")
    end)

    local sent, err = send("data")
    assert.is_nil(sent)
    assert.equal("closed", err)
  end)

  it("receives once and passes through errors", function()
    local arguments
    local receive = so.recving({
      receive = function(_, ...)
        arguments = { ... }
        return "data"
      end
    }, function()
      error("timeout callback should not run")
    end)

    assert.equal("data", receive("*l", "prefix"))
    assert.same({ "*l", "prefix" }, arguments)
  end)

  it("retries timed-out receives with the partial data", function()
    local attempts = {}
    local timeouts = 0
    local receive = so.recving({
      receive = function(_, ...)
        table.insert(attempts, { ... })
        if #attempts == 1 then
          return nil, "timeout", "partial"
        end
        return "complete"
      end
    }, function()
      timeouts = timeouts + 1
    end)

    assert.equal("complete", receive("*l", "prefix"))
    assert.equal(1, timeouts)
    assert.same({
      { "*l", "prefix" },
      { "*l", "partial" }
    }, attempts)
  end)

  it("returns non-timeout receive errors", function()
    local receive = so.recving({
      receive = function()
        return nil, "closed"
      end
    }, function()
      error("timeout callback should not run")
    end)

    local data, err = receive("*l")
    assert.is_nil(data)
    assert.equal("closed", err)
  end)
end)
