describe("resp", function()
  it("exports the null marker and version-2 protocol", function()
    local resp = require "resp"

    assert.equal(require "resp.null", resp.null)
    assert.equal(require "resp.v2", resp.v2)
  end)
end)
