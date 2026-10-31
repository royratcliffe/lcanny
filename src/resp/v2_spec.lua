require "busted.runner" {}

describe("resp.v2", function()
  local resp = {
    v2 = require "resp.v2"
  }
  local socket = {
    core = require "socket.core"
  }

  local tcp = assert(socket.core.tcp())
  assert(tcp:connect(os.getenv("REDISCLI_HOST") or "localhost", 6379))

  local function send(...)
    return resp.v2.send.recursive(function(...)
      return tcp:send(...)
    end, ...)
  end

  local function recv()
    return resp.v2.recv.recursive(function(...)
      return tcp:receive(...)
    end)
  end

  it("lolwut", function()
    assert.truthy(send { "LOLWUT" })
    assert.matches("^Redis ver%. %d+%.%d+%.%d+\n$", recv())
  end)

  describe("hi", function()
    local hi = require "hi"

    local redis = {
      call = hi.calling(send, recv)
    }

    it("works", function()
      assert.truthy(redis.call { "INFO" })
    end)
  end)
end)
