describe("redis", function()
  local function load_with_socket(socket, host)
    local original_socket = package.loaded["socket.core"]
    local original_redis = package.loaded.redis
    local original_getenv = os.getenv

    package.loaded["socket.core"] = socket
    package.loaded.redis = nil
    rawset(os, "getenv", function(name)
      if name == "REDISCLI_HOST" then
        return host
      end
      return original_getenv(name)
    end)

    local ok, result = pcall(require, "redis")

    package.loaded["socket.core"] = original_socket
    package.loaded.redis = original_redis
    rawset(os, "getenv", original_getenv)

    return ok, result
  end

  it("connects using the configured host and exposes a RESP caller", function()
    local connected
    local sent = {}
    local tcp = {
      connect = function(_, host, port)
        connected = { host, port }
        return true
      end,
      send = function(_, data)
        table.insert(sent, data)
        return #data
      end,
      receive = function()
        return "+PONG"
      end
    }
    local ok, redis = load_with_socket({
      tcp = function()
        return tcp
      end
    }, "redis.example")

    assert.is_true(ok)
    assert.same({ "redis.example", 6379 }, connected)
    assert.equal("PONG", redis.call({ "PING" }))
    assert.same({ "*1\r\n", "$4\r\nPING\r\n" }, sent)
  end)

  it("defaults to localhost and reports connection failures", function()
    local connected
    local tcp = {
      connect = function(_, host, port)
        connected = { host, port }
        return nil, "connection failed"
      end
    }
    local ok, err = load_with_socket({
      tcp = function()
        return tcp
      end
    })

    assert.is_false(ok)
    assert.matches("connection failed", err)
    assert.same({ "localhost", 6379 }, connected)
  end)

  it("reports failure to create a TCP socket", function()
    local ok, err = load_with_socket({
      tcp = function()
        return nil, "socket unavailable"
      end
    })

    assert.is_false(ok)
    assert.matches("socket unavailable", err)
  end)
end)
