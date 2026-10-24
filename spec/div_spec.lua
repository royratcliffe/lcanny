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

  describe("rem", function()
    it("adjusts the quotient only when the modulo is negative", function()
      local cases = {
        { 7,  3,  2,  1 },  -- positive dividend, positive divisor
        { -7, 3,  -3, 2 },  -- negative dividend, positive divisor
        { 7,  -3, -4, -2 }, -- positive dividend, negative divisor
        { -7, -3, 1,  -1 }, -- negative dividend, negative divisor
        { 1,  3,  0,  1 },  -- positive dividend, positive divisor
        { -1, 3,  -1, 2 },  -- negative dividend, positive divisor
        { 1,  -3, -2, -2 }, -- positive dividend, negative divisor
        { -1, -3, -1, -1 }, -- negative dividend, negative divisor
      }
      for _, case in ipairs(cases) do
        assert.same({ case[3], case[4] }, { div.rem(case[1], case[2]) },
          "dividend " .. case[1] .. ", divisor " .. case[2])
      end
    end)

    it("leaves exact quotients unchanged for either divisor sign", function()
      for divisor = -10, 10 do
        if divisor ~= 0 then
          for quotient = -10, 10 do
            assert.same({ quotient, 0 }, { div.rem(quotient * divisor, divisor) })
          end
        end
      end
    end)

    it("supports fractional dividends and divisors", function()
      local cases = {
        { 5.5,   2,    2,  1.5 },   -- positive dividend, positive divisor
        { -5.5,  2,    -3, 0.5 },   -- negative dividend, positive divisor
        { 5.5,   -2,   -4, -0.5 },  -- positive dividend, negative divisor
        { -5.5,  -2,   1,  -1.5 },  -- negative dividend, negative divisor
        { 1.25,  0.5,  2,  0.25 },  -- positive fractional dividend, positive fractional divisor
        { -1.25, 0.5,  -3, 0.25 },  -- negative fractional dividend, positive fractional divisor
        { 1.25,  -0.5, -4, -0.25 }, -- positive fractional dividend, negative fractional divisor
        { -1.25, -0.5, 1,  -0.25 }, -- negative fractional dividend, negative fractional divisor
      }
      for _, case in ipairs(cases) do
        assert.same({ case[3], case[4] }, { div.rem(case[1], case[2]) },
          "dividend " .. case[1] .. ", divisor " .. case[2])
      end
    end)
  end)
end)
