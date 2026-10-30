require "busted.runner" {}

describe("co", function()
  local co = require "co"

  it("works", function()
    local on = co(function(...)
      print("co", ...)
    end, 1, 2, 3)
  end)
end)
