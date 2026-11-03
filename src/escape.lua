--- URL-like escape encoding and decoding helpers.
-- Provides functions to escape reserved URL characters and restore them from
-- percent-encoded form.
-- @module escape
local _M = {
  --- Pattern used to match any non-alphanumeric, non-underscore character.
  -- This is the default matcher for escaped characters such as spaces,
  -- punctuation, and symbols.
  -- @tfield string PAT Lua pattern used for URL escaping.
  PAT = "([^%a%d_])",
  --- Escape sequence used for encoding.
  -- This is the literal percent sign (`%`) used in URL encoding, albeit escaped
  -- as `%%` for Lua regular expressions. This sequence is used as a prefix for
  -- encoded characters.
  -- @tfield string ESC Escape sequence used for encoding.
  ESC = "%%"
}

--- Escapes reserved characters in a string for use in a URL.
-- Each matched character is replaced with a percent-encoded byte value in
-- hexadecimal form, for example a space becomes `%20`.
-- @tparam string str String to escape.
-- @tparam[opt] string pat Lua pattern to match characters to encode.
--   When omitted, `PAT` is used.
-- @treturn string Escaped string.
-- @treturn number Number of substitutions performed.
function _M.en(str, pat)
  return string.gsub(str, pat or _M.PAT, function(chr)
    return string.format(_M.ESC .. "%02x", string.byte(chr))
  end)
end

--- Decodes a percent-encoded URL string back to its original form.
-- Converts sequences like `%20` or `%2f` into their corresponding characters.
-- @tparam string str String to unescape.
-- @treturn string Unescaped string.
function _M.un(str)
  return string.gsub(str, _M.ESC .. "(%x%x)", function(hex)
    return string.char(tonumber(hex, 16))
  end)
end

return _M
