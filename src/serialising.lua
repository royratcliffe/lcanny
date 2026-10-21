--- Lua serialisation.
-- @module serialising
-- @author Roy Ratcliffe
-- @copyright 2024
-- @license MIT
local _M = {}
local is = require "is"
local by = require "by"
local collecting = require "collecting"

--- Serialises anything using its type.
-- @param value Anything to serialise.
-- @tparam ?string index String to use as the index.
-- @tparam ?string indent Indentation string.
-- @tparam ?string offset Current offset string.
-- @treturn string Lua source code.
function _M.value(value, index, indent, offset)
  local serialise = _M[type(value)]
  return serialise and serialise(value, index, indent, offset) or "nil"
end

--- Index and indent to string.
-- @tparam ?string index String for use as index.
-- @tparam ?string indent Indentation string.
-- @treturn string Lua source code.
local function indexindent(index, indent)
  return (indent or "")..(index or "")..(index and " = " or "")
end

--- Serialises a number, or boolean.
-- @tparam number|bool value Number or boolean to serialise.
-- @tparam ?string index Index of number or boolean.
-- @tparam ?string indent Indentation if any.
-- @treturn string Lua source code.
local function anytostring(value, index, indent)
  return indexindent(index, indent)..tostring(value)
end

_M.number = anytostring

_M.boolean = anytostring

--- Serialises a string.
-- Quotes the string.
-- @tparam string value String to serialise.
-- @tparam ?string index Index of string.
-- @tparam ?string indent Indentation.
-- @treturn string Lua source code.
function _M.string(value, index, indent)
  return indexindent(index, indent)..string.format("%q", value)
end

local function index_(index)
  local isidentifier = type(index) == "string" and is.identifier(index)
  return isidentifier and index or "[".._M.value(index).."]"
end

--- Recursively serialises a table.
--
-- Recursively serialises a table to Lua code with optional indent and
-- offset, defaulting to blank indent and tab offset. Serialises only
-- numeric and string indices. Sorts the indices; sorted numeric indices
-- first, then sorted strings. Answers a multi-line string but without a
-- new-line terminator, by design. Add a terminator externally if
-- needed.
--
-- Serialises only number and string indices. Sorts numbers and strings
-- separately by design. This is important when `table.sort` has been
-- redefined for string-only UTF-8 sorting, for example. Avoids
-- comparing numbers and strings when the default table sorter cannot
-- handle number-string comparisons.
--
-- Serialises string indices, but elides the double quotes and square
-- brackets if the index begins with a letter (upper or lower case)
-- followed by zero or more letters, digits or underscores.
--
-- Does not detect circular recursions.
--
-- @tparam table value Table to serialise.
-- @tparam ?string index Index of table.
-- @tparam ?string indent Indentation string, defaulting to "".
-- @tparam ?string offset Initial offset string, defaulting to "\t".
-- @treturn string Lua source code.
function _M.table(value, index, indent, offset)
  indent = indent or ""
  offset = offset or "\t"
  local strs = {}
  if is.array(value) then
    for _, subvalue in ipairs(value) do
      table.insert(strs, _M.value(subvalue, nil, indent..offset, offset))
    end
  else
    local function indices_(indices)
      table.sort(indices)
      for _, subindex in ipairs(indices) do
        table.insert(strs, _M.value(value[subindex], index_(subindex), indent..offset, offset))
      end
    end
    local indicesbytype = by.group(type, collecting.values(pairs(value)))
    if indicesbytype.number then
      indices_(indicesbytype.number)
    end
    if indicesbytype.string then
      indices_(indicesbytype.string)
    end
  end
  local str = indexindent(index, indent).."{"
  if #strs > 0 then
    str = str.."\n"..table.concat(strs, ",\n").."\n"..indent
  end
  return str.."}"
end

return _M
