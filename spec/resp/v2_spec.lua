require "busted.runner" {}

describe("resp.v2", function()
  local resp = require "resp.v2"
  local send = resp.send
  local recv = resp.recv

  it("exports the RESP null value", function()
    assert.equal(require "resp.null", require("resp").null)
  end)

  it("sends numbers, strings, and recursive arrays", function()
    local sent = {}
    local function sending(data)
      table.insert(sent, data)
      return #data
    end

    assert.equal(5, send.recursive(sending, 42))
    assert.equal(11, send.recursive(sending, "hello"))
    assert.equal(
      15,
      send.recursive(sending, { 1, "x" })
    )
    assert.same({
      ":42\r\n",
      "$5\r\nhello\r\n",
      "*2\r\n",
      ":1\r\n",
      "$1\r\nx\r\n"
    }, sent)
  end)

  it("rejects values with no RESP serializer", function()
    assert.has_error(function()
      send.recursive(function() end, function() end)
    end)
  end)

  it("receives simple values, errors, nulls, and recursive arrays", function()
    local responses = {
      ":42",
      "+OK",
      "-ERR failed",
      "$-1",
      "*3",
      "+item",
      ":2",
      "$-1"
    }
    local patterns = {}
    local function receiving(pattern)
      table.insert(patterns, pattern)
      return table.remove(responses, 1)
    end

    assert.equal(42, recv.recursive(receiving))
    assert.equal("OK", recv.recursive(receiving))
    local value, err = recv.recursive(receiving)
    assert.is_nil(value)
    assert.equal("ERR failed", err)
    assert.equal(require "resp.null", recv.recursive(receiving))
    assert.same({ "item", 2, require "resp.null" }, recv.recursive(receiving))
    assert.same({
      "*l", "*l", "*l", "*l", "*l", "*l", "*l", "*l"
    }, patterns)
  end)

  it("receives bulk strings using their length", function()
    local responses = { "$3", "" }
    local patterns = {}
    local function receiving(pattern)
      table.insert(patterns, pattern)
      if pattern == 3 then
        return "abc"
      end
      return table.remove(responses, 1)
    end

    assert.equal("abc", recv.recursive(receiving))
    assert.same({ "*l", 3, "*l" }, patterns)
    assert.same({}, responses)
  end)

  it("rejects malformed or unknown RESP messages", function()
    assert.has_error(function()
      recv.recursive(function()
        return nil
      end)
    end)
    assert.has_error(function()
      recv.recursive(function()
        return "?unknown"
      end)
    end)
    assert.has_error(function()
      recv.recursive(function()
        return ":not a number"
      end)
    end)
  end)

  it("builds a blocking calling function around a TCP socket", function()
    local sent = {}
    local tcp = {
      send = function(_, data)
        table.insert(sent, data)
        return #data
      end,
      receive = function(_, pattern)
        assert.equal("*l", pattern)
        return "+PONG"
      end
    }

    assert.equal("PONG", resp.calling(tcp)({ "PING" }))
    assert.same({ "*1\r\n", "$4\r\nPING\r\n" }, sent)
  end)

  it("builds resumable sending and receiving functions", function()
    local sent = {}
    local timeout
    local tcp = {
      settimeout = function(_, value)
        timeout = value
        return 1
      end,
      send = function(_, data)
        table.insert(sent, data)
        return #data
      end,
      receive = function(_, pattern)
        assert.equal("*l", pattern)
        return "+OK"
      end
    }
    local call, sending, receiving = resp.resuming(tcp)

    assert.equal(0, timeout)
    assert.equal("OK", call({ "PING" }))
    assert.equal(4, sending(1))
    assert.equal("OK", receiving())
    assert.same({ "*1\r\n", "$4\r\nPING\r\n", ":1\r\n" }, sent)
  end)

  it("scans keys across cursor pages", function()
    local requests = {}
    local pages = {
      { "1", { "a", "b" } },
      { "0", { "c" } }
    }
    local function call(request)
      table.insert(requests, request)
      return table.remove(pages, 1)
    end
    local keys = resp.scan(call, "MATCH", "item:*")

    assert.same({ "a", "b", "c" }, { keys(), keys(), keys() })
    assert.is_nil(keys())
    assert.same({
      { "SCAN", "0", "MATCH", "item:*" },
      { "SCAN", "1", "MATCH", "item:*" }
    }, requests)
  end)

  it("scans hash fields across cursor pages", function()
    local requests = {}
    local pages = {
      { "2", { "a", "b" } },
      { "0", { "c" } }
    }
    local function call(request)
      table.insert(requests, request)
      return table.remove(pages, 1)
    end
    local fields = resp.hscan(call, "hash", "COUNT", 3)

    assert.same({ "a", "b", "c" }, { fields(), fields(), fields() })
    assert.is_nil(fields())
    assert.same({
      { "HSCAN", "hash", "0", "COUNT", 3 },
      { "HSCAN", "hash", "2", "COUNT", 3 }
    }, requests)
  end)

  it("scans set members across cursor pages", function()
    local requests = {}
    local pages = {
      { "3", { "a" } },
      { "0", { "b" } }
    }
    local function call(request)
      table.insert(requests, request)
      return table.remove(pages, 1)
    end
    local members = resp.sscan(call, "set")

    assert.same({ "a", "b" }, { members(), members() })
    assert.is_nil(members())
    assert.same({
      { "SSCAN", "set", "0" },
      { "SSCAN", "set", "3" }
    }, requests)
  end)

  it("iterates stream entries and collapses fields", function()
    local entries = resp.entries({
      {
        "stream",
        {
          { "1-0", { "name", "Ada", "active", "yes" } },
          { "2-0", { "name", "Lin" } }
        }
      }
    })

    assert.same({
      "stream", "1-0", { name = "Ada", active = "yes" }
    }, { entries() })
    assert.same({
      "stream", "2-0", { name = "Lin" }
    }, { entries() })
    assert.is_nil(entries())
  end)
end)
