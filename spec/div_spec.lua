describe("div", function()
  local div = require "div"

  it("mod", function()
    for x = -3, 3 do
      for y = -3, 3 do
        if y ~= 0 then
          local quo, mod = div.mod(x, y)
          assert.equal(x, y * quo + mod)
          print(x, y, quo, mod)
        end
      end
    end
  end)
end)
