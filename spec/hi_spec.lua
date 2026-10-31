describe("hi", function()
  local hi = require "hi"

  it("sends a command before receiving its reply", function()
    local calls = {}
    local call = hi.calling(function(command)
      table.insert(calls, { "send", command })
      return true
    end, function()
      table.insert(calls, { "receive" })
      return "reply", "error"
    end)

    assert.same({ "reply", "error" }, { call("command") })
    assert.same({ { "send", "command" }, { "receive" } }, calls)
  end)

  it("asserts failed sends", function()
    local call = hi.calling(function()
      return nil, "send failed"
    end, function()
      error("receive should not run")
    end)

    assert.has_error(function()
      call("command")
    end)
  end)
end)
