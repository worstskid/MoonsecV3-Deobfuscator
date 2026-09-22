local byte = string.byte
local chr = string.char
local sub = string.sub
local gsub = string.gsub
local find = string.find
local format = string.format
local floor = math.floor
local table_concat = table.concat
local error = error
local setmetatable = setmetatable
local tonumber = tonumber
local tostring = tostring

-- Public set of token type names returned by every scanner. Callers should
-- treat this exported table as read-only.
local token_types = {
  ["EOF"] = true,
  ["BooleanLiteral"] = true,
  ["NumberLiteral"] = true,
  ["StringLiteral"] = true,
  ["NilLiteral"] = true,
  ["VarargLiteral"] = true,
  ["Keyword"] = true,
  ["Identifier"] = true,
  ["Punctuator"] = true,
  ["Comment"] = true,
}

local feature_profiles = {
  ["5.1"] = {
    identifier_mode = "locale",
  },
  ["LuaJIT"] = {
    identifier_mode = "extended",
    labels = true,
    hex_floats = true,
    binary_numbers = true,
    integer_suffixes = true,
    imaginary_numbers = true,
    hex_escapes = true,
    skip_whitespace_escape = true,
    unicode_escapes = true,
    strict_escapes = true,
  },
  ["5.2"] = {
    identifier_mode = "ascii",
    goto_keyword = true,
    labels = true,
    hex_floats = true,
    hex_escapes = true,
    skip_whitespace_escape = true,
    strict_escapes = true,
  },
  ["5.3"] = {
    identifier_mode = "ascii",
    goto_keyword = true,
    labels = true,
    hex_floats = true,
    hex_escapes = true,
    skip_whitespace_escape = true,
    unicode_escapes = true,
    strict_escapes = true,
    bitwise_operators = true,
    integer_division = true,
  },
  ["5.4"] = {
    identifier_mode = "ascii",
    goto_keyword = true,
    labels = true,
    hex_floats = true,
    hex_escapes = true,
    skip_whitespace_escape = true,
    unicode_escapes = true,
    strict_escapes = true,
    bitwise_operators = true,
    integer_division = true,
  },
  ["5.5"] = {
    identifier_mode = "ascii",
    goto_keyword = true,
    global_keyword = true,
    labels = true,
    hex_floats = true,
    hex_escapes = true,
    skip_whitespace_escape = true,
    unicode_escapes = true,
    strict_escapes = true,
    bitwise_operators = true,
    integer_division = true,
  },
}

-- Keyword keys use a collision-free base-26 encoding. Starting at 1 keeps
-- leading "a" bytes significant even though "a" maps to 0:
--   key = 1
--   key = key * 26 + byte - byte("a") -- for each lowercase byte
-- Identifiers considered here are at most 8 bytes, so every key is an exact
-- integer in Lua's default double-precision number representation.
local keywords = {
  [14174164] = "BooleanLiteral", -- false
  [802936] = "BooleanLiteral", -- true

  [26583] = "NilLiteral", -- nil

  [17917] = "Keyword", -- and
  [12639858] = "Keyword", -- break
  [768] = "Keyword", -- do
  [535188] = "Keyword", -- else
  [361787301] = "Keyword", -- elseif
  [20621] = "Keyword", -- end
  [21337] = "Keyword", -- for
  [255320142545] = "Keyword", -- function
  [572404] = "Keyword", -- goto
  [385477519] = "Keyword", -- global
  [889] = "Keyword", -- if
  [897] = "Keyword", -- in
  [17155539] = "Keyword", -- local
  [26747] = "Keyword", -- not
  [1057] = "Keyword", -- or
  [512993435] = "Keyword", -- repeat
  [513074991] = "Keyword", -- return
  [795769] = "Keyword", -- then
  [21262447] = "Keyword", -- until
  [22063578] = "Keyword", -- while
}

local escaped2char = {
  [97] = "\a",
  [98] = "\b",
  [102] = "\f",
  [110] = "\n",
  [114] = "\r",
  [116] = "\t",
  [118] = "\v",
  [92] = "\\",
  [39] = "'",
  [34] = '"',
}

local function is_identifier_start(c, features)
  if c < 128 then
    -- _ or A-Z or a-z
    return c == 95 or (65 <= c and c <= 90) or (97 <= c and c <= 122)
  end

  local id_mode = features.identifier_mode
  return id_mode == "extended" or (id_mode == "locale" and find(chr(c), "%a"))
end

local function is_digit(c)
  return 48 <= c and c <= 57 -- 0-9
end

local function is_hex_digit(c)
  return (48 <= c and c <= 57) -- 0-9
    or (65 <= c and c <= 70) -- A-F
    or (97 <= c and c <= 102) -- a-f
end

local function is_binary_digit(char) return char == 48 or char == 49 end

-- undefined if is_hex_digit(c) is false
local function hex_digit_value(c)
  if c <= 57 then return c - 48 end -- 0-9
  if c <= 70 then return c - 55 end -- A-F, 55 is string.byte("A") - 10
  return c - 87 -- a-f, 87 is string.byte("a") - 10
end

local function is_identifier_part(c, features)
  if is_digit(c) or is_identifier_start(c, features) then return true end
  return c >= 128
    and features.identifier_mode == "locale"
    and find(chr(c), "%w")
end

local function is_ascii_lower(c)
  return 97 <= c and c <= 122 -- a-z
end

local function is_whitespace(c)
  -- tab, LF, vertical tab, form feed, CR and space
  return 9 <= c and c <= 13 or c == 32
end

local function scan_identifier_keyword(input, index, features)
  local first = byte(input, index)
  local keyword_key = is_ascii_lower(first) and 26 + first - 97 or 0

  for i = index + 1, #input do
    local char = byte(input, i)
    if not is_identifier_part(char, features) then return i, keyword_key end
    if keyword_key ~= 0 then
      if i - index < 8 and is_ascii_lower(char) then
        keyword_key = keyword_key * 26 + char - 97
      else
        keyword_key = 0
      end
    end
  end
  return #input + 1, keyword_key
end

local function skip_whitespaces(input, index)
  for i = index, #input do
    if not is_whitespace(byte(input, i)) then return i end
  end
  return #input + 1
end

local function scan_long_string_opener(input, index)
  local length = #input
  if index > length or byte(input, index) ~= 91 then -- [
    return index
  end

  local i = index + 1
  while i <= length and byte(input, i) == 61 do -- =
    i = i + 1
  end

  return (i <= length and byte(input, i) == 91) and i + 1 or index
end

local function scan_long_string(input, index)
  local i = scan_long_string_opener(input, index)
  if i == index then return index end

  local length = #input
  local level = i - index - 2 -- level is the number of "=" in the opener

  while i <= length do
    if byte(input, i) == 93 then -- ]
      local j = i + 1
      local n = 0

      while n < level and j <= length and byte(input, j) == 61 do -- =
        j = j + 1
        n = n + 1
      end

      if n == level and j <= length and byte(input, j) == 93 then -- ]
        return j + 1
      end

      i = j
    else
      i = i + 1
    end
  end

  return index, "malformed long string"
end

local function long_string_value(input, index, end_ind)
  local content_start = scan_long_string_opener(input, index)
  local level = content_start - index - 2
  local content = sub(input, content_start, end_ind - level - 3)

  local first = byte(content, 1)
  if first == 10 or first == 13 then -- newline or carriage return
    local second = byte(content, 2)
    local another = first == 10 and 13 or 10
    content = sub(content, second == another and 3 or 2)
  end

  -- Lua normalizes LF, CR, CRLF and LFCR to a single LF.
  content = gsub(content, "\r\n", "\n")
  content = gsub(content, "\n\r", "\n")
  return gsub(content, "\r", "\n")
end

-- in a quoted string, a character is used as-is if it is not
-- corresponding quote, backslash, newline, and carriage return
local function is_as_is_char(char, quote)
  return char ~= quote and char ~= 92 and char ~= 10 and char ~= 13
end

-- encode a unicode codepoint as UTF-8 sequences string
local function encode_utf8_impl(codepoint)
  if codepoint <= 0x7f then
    return chr(codepoint)
  elseif codepoint <= 0x7ff then
    return chr(0xc0 + floor(codepoint / 0x40), 0x80 + codepoint % 0x40)
  elseif codepoint <= 0xffff then
    return chr(
      0xe0 + floor(codepoint / 0x1000),
      0x80 + floor(codepoint / 0x40) % 0x40,
      0x80 + codepoint % 0x40
    )
  elseif codepoint <= 0x1fffff then
    return chr(
      0xf0 + floor(codepoint / 0x40000),
      0x80 + floor(codepoint / 0x1000) % 0x40,
      0x80 + floor(codepoint / 0x40) % 0x40,
      0x80 + codepoint % 0x40
    )
  elseif codepoint <= 0x3ffffff then
    return chr(
      0xf8 + floor(codepoint / 0x1000000),
      0x80 + floor(codepoint / 0x40000) % 0x40,
      0x80 + floor(codepoint / 0x1000) % 0x40,
      0x80 + floor(codepoint / 0x40) % 0x40,
      0x80 + codepoint % 0x40
    )
  end
  return chr(
    0xfc + floor(codepoint / 0x40000000),
    0x80 + floor(codepoint / 0x1000000) % 0x40,
    0x80 + floor(codepoint / 0x40000) % 0x40,
    0x80 + floor(codepoint / 0x1000) % 0x40,
    0x80 + floor(codepoint / 0x40) % 0x40,
    0x80 + codepoint % 0x40
  )
end

local runtime_version = tonumber(_VERSION:match("Lua 5%.(%d+)"))
local encode_utf8 = runtime_version ~= nil
    and runtime_version > 3
    and utf8
    and utf8.char
  or encode_utf8_impl

-- to scan a lua '\u{XXX}' unicode escape,
-- when valid, return index past close brace and utf8 byte sequence string
-- when invalid, return `index` and an error message
local function scan_unicode_escape(input, index, need_value)
  local length = #input
  local i = index + 1
  if i > length or byte(input, i) ~= 123 then -- {
    return index, "missing opening brace in unicode escape"
  end

  i = i + 1
  local codepoint = 0
  while i <= length do
    local char = byte(input, i)
    if not is_hex_digit(char) then break end
    codepoint = codepoint * 16 + hex_digit_value(char)
    if codepoint >= 0x80000000 then return index, "unicode escape too large" end
    i = i + 1
  end

  if i > length or byte(input, i) ~= 125 then -- }
    return index, "missing closing brace in unicode escape"
  end
  if i <= index + 2 then return index, "unicode escape cannot be empty" end

  return i + 1, need_value and encode_utf8(codepoint) or ""
end

-- there are 3 cases:
-- 1. invalid quoted string literal, return index, reason
-- 2. need_value is true,
--   return index after close quote character, string value of the quoted string
-- 3. need_value is false,
--   return index after close quote character and empty string (for consistency)
local function scan_quote_string(input, index, need_value, features)
  local quote = byte(input, index)
  local length = #input
  local values = need_value and {} or nil
  local i = index + 1

  while i <= length do
    local char = byte(input, i)
    if char == quote then
      return i + 1, values and table_concat(values) or ""
    elseif char == 92 then -- the escape character
      i = i + 1
      if i > length then return index, "escape character at end of input" end
      local escaped = byte(input, i)
      local single_escaped = escaped2char[escaped]
      if single_escaped ~= nil then
        if values then values[#values + 1] = single_escaped end
        i = i + 1
      elseif escaped == 10 or escaped == 13 then -- newline or carriage return
        if i >= length then break end
        -- lua normalizes LF, CR, CRLF and LFCR to a single LF
        if values then values[#values + 1] = "\n" end
        local another = escaped == 10 and 13 or 10
        i = i + (byte(input, i + 1) == another and 2 or 1)
      elseif is_digit(escaped) then
        -- scan digits but at most 3 characters
        local j = i + 1
        local value = escaped - 48
        while j <= length and j < i + 3 do
          local j_char = byte(input, j)
          if not is_digit(j_char) then break end
          value = value * 10 + j_char - 48
          j = j + 1
        end
        if value > 255 then return index, "decimal escape too large" end
        if values then values[#values + 1] = chr(value) end
        i = j
      elseif escaped == 120 and features.hex_escapes then -- x
        if
          i + 2 > length
          or not is_hex_digit(byte(input, i + 1))
          or not is_hex_digit(byte(input, i + 2))
        then
          return index, "hexadecimal digit expected"
        end
        local value = hex_digit_value(byte(input, i + 1)) * 16
          + hex_digit_value(byte(input, i + 2))
        if values then values[#values + 1] = chr(value) end
        i = i + 3
      elseif escaped == 122 and features.skip_whitespace_escape then -- z
        i = skip_whitespaces(input, i + 1)
      elseif escaped == 117 and features.unicode_escapes then -- u
        local next_index, value_or_err = scan_unicode_escape(input, i, values)
        if next_index == i then return index, value_or_err end
        if values then values[#values + 1] = value_or_err end
        i = next_index
      elseif features.strict_escapes then
        return index, "invalid escape sequence"
      else
        if values then values[#values + 1] = chr(escaped) end
        i = i + 1
      end
    elseif char == 10 or char == 13 then -- newline or carriage return
      break
    else
      if values then
        local j = i + 1
        while j <= length and is_as_is_char(byte(input, j), quote) do
          j = j + 1
        end
        if j > length then break end
        values[#values + 1] = sub(input, i, j - 1)
        i = j
      else
        i = i + 1
      end
    end
  end

  return index, "unfinished string"
end

local function scan_digits(input, index, is_valid_digit)
  for i = index, #input do
    if not is_valid_digit(byte(input, i)) then return i end
  end
  return #input + 1
end

local function scan_mantissa(input, index, is_valid_digit)
  local integer_end = scan_digits(input, index, is_valid_digit)
  local i = integer_end
  local has_radix_point = i <= #input and byte(input, i) == 46 -- .
  if has_radix_point then i = scan_digits(input, i + 1, is_valid_digit) end

  -- Require at least one digit on either side of the radix point.
  if integer_end == index and i <= index + 1 then return index, false end
  return i, has_radix_point
end

local function scan_exponent(input, index, upper, lower)
  if index > #input then return index end
  local marker = byte(input, index)
  if marker ~= upper and marker ~= lower then return index end

  local i = index + 1
  if i <= #input then
    local char = byte(input, i)
    if char == 43 or char == 45 then i = i + 1 end -- "+" or "-"
  end

  -- Leave an unfinished exponent for the malformed-number boundary check.
  if i > #input or not is_digit(byte(input, i)) then return index end
  return scan_digits(input, i, is_digit)
end

local function starts_with_0(input, index, upper, lower)
  if index >= #input or byte(input, index) ~= 48 then -- "0"
    return false
  end

  local second = byte(input, index + 1)
  return second == lower or second == upper
end

local function is_number_continuation(s, index, features)
  if index > #s then return false end
  local char = byte(s, index)
  -- . or identifier part (digit or letter or underscore)
  return char == 46 or is_identifier_part(char, features)
end

local function scan_integer_suffix(input, index)
  local first = byte(input, index)
  if first == 85 or first == 117 then -- "U" or "u"
    local second = byte(input, index + 1)
    local third = byte(input, index + 2)
    if
      (second == 76 or second == 108) -- "L" or "l"
      and (third == 76 or third == 108)
    then
      return index + 3
    end
  elseif first == 76 or first == 108 then -- "L" or "l"
    local second = byte(input, index + 1)
    if second == 76 or second == 108 then return index + 2 end
  end
  return index
end

local function scan_number(input, index, features)
  local i, has_fraction

  if starts_with_0(input, index, 88, 120) then -- "0x" or "0X"
    local mantissa_start = index + 2
    if features.hex_floats then
      local mantissa_end, has_radix_point =
        scan_mantissa(input, mantissa_start, is_hex_digit)
      if mantissa_end == mantissa_start then return index end
      i = scan_exponent(input, mantissa_end, 80, 112) -- "P" or "p"
      has_fraction = has_radix_point or i > mantissa_end
    else
      i = scan_digits(input, mantissa_start, is_hex_digit)
      if i == mantissa_start then return index end
    end
  elseif starts_with_0(input, index, 66, 98) then -- "0b" or "0B"
    if not features.binary_numbers then return index end
    local digit_start = index + 2
    i = scan_digits(input, digit_start, is_binary_digit)
    if i == digit_start then return index end
    has_fraction = false
  else
    local mantissa_end, has_radix_point = scan_mantissa(input, index, is_digit)
    if mantissa_end == index then return index end
    i = scan_exponent(input, mantissa_end, 69, 101) -- "E" or "e"
    has_fraction = has_radix_point or i > mantissa_end
  end

  local has_imaginary = false
  if features.imaginary_numbers then
    local char = byte(input, i)
    if char == 73 or char == 105 then -- "I" or "i"
      i = i + 1
      has_imaginary = true
    end
  end
  return (has_fraction or has_imaginary or not features.integer_suffixes) and i
    or scan_integer_suffix(input, i)
end

local function scan_comment(input, index)
  local length = #input
  if
    index >= length
    or byte(input, index) ~= 45 -- -
    or byte(input, index + 1) ~= 45 -- -
  then
    return index
  end

  local comment_start = index + 2
  local long_comment_end, long_string_error =
    scan_long_string(input, comment_start)
  if long_string_error ~= nil then return index, "malformed long comment" end
  if long_comment_end > comment_start then return long_comment_end end

  for i = comment_start, length do
    local char = byte(input, i)
    -- \n or \r
    if char == 10 or char == 13 then return i end
  end
  return length + 1
end

local function scan_punctuator(input, index, features)
  local length = #input
  if index > length then return index end

  local first = byte(input, index)
  local second = index < length and byte(input, index + 1) or -1
  if
    (first == 61 and second == 61) -- ==
    or (first == 126 and second == 61) -- ~=
    or (first == 60 and second == 61) -- <=
    or (first == 62 and second == 61) -- >=
    or (first == 46 and second == 46) -- ..
    or (features.labels and first == 58 and second == 58) -- ::
    or (features.bitwise_operators and first == 60 and second == 60) -- <<
    or (features.bitwise_operators and first == 62 and second == 62) -- >>
    or (features.integer_division and first == 47 and second == 47) -- //
  then
    return index + 2
  end

  if
    first == 43 -- +
    or first == 45 -- -
    or first == 42 -- *
    or first == 47 -- /
    or first == 37 -- %
    or first == 94 -- ^
    or first == 35 -- #
    or first == 60 -- <
    or first == 62 -- >
    or first == 61 -- =
    or first == 40 -- (
    or first == 41 -- )
    or first == 123 -- {
    or first == 125 -- }
    or first == 91 -- [
    or first == 93 -- ]
    or first == 59 -- ;
    or first == 58 -- :
    or first == 44 -- ,
    or first == 46 -- .
    or (features.bitwise_operators and first == 38) -- &
    or (features.bitwise_operators and first == 124) -- |
    or (features.bitwise_operators and first == 126) -- ~
  then
    return index + 1
  end

  return index
end

local function scan_vararg(input, index)
  return (
    index + 2 <= #input
    and byte(input, index) == 46 -- "."
    and byte(input, index + 1) == 46
    and byte(input, index + 2) == 46
  )
      and index + 3
    or index
end

local function scan_token(features, input, index)
  local length = #input
  if index > length then return "EOF", index end
  local first = byte(input, index)
  if is_whitespace(first) then
    index = skip_whitespaces(input, index + 1)
    if index > length then return "EOF", index end
    first = byte(input, index)
  end

  -- dispatch based on first character
  if is_identifier_start(first, features) then
    local end_ind, keyword_key = scan_identifier_keyword(input, index, features)
    if end_ind - index > 8 or keyword_key == 0 then
      return "Identifier", end_ind
    end
    local t = keywords[keyword_key]
    if keyword_key == 572404 and not features.goto_keyword then t = nil end
    if keyword_key == 385477519 and not features.global_keyword then t = nil end
    if t == nil then t = "Identifier" end
    return t, end_ind
  elseif is_digit(first) then
    -- because plain decimal-integer is most common, make it a fast path
    local end_ind = index + 1
    while end_ind <= length and is_digit(byte(input, end_ind)) do
      end_ind = end_ind + 1
    end
    if not is_number_continuation(input, end_ind, features) then
      return "NumberLiteral", end_ind
    end

    end_ind = scan_number(input, index, features)
    if end_ind == index or is_number_continuation(input, end_ind, features) then
      return format("malformed number near %d", index), index
    end
    return "NumberLiteral", end_ind
  elseif first == 46 then -- .
    local end_ind = scan_vararg(input, index)
    if end_ind > index then return "VarargLiteral", end_ind end

    end_ind = scan_number(input, index, features)
    if end_ind > index then
      if is_number_continuation(input, end_ind, features) then
        return format("malformed number near %d", index), index
      end
      return "NumberLiteral", end_ind
    end

    end_ind = scan_punctuator(input, index, features)
    if end_ind > index then return "Punctuator", end_ind end
    return format("unknown token after . near %d", index), index
  elseif first == 45 then -- -
    local end_ind, comment_error = scan_comment(input, index)
    if comment_error ~= nil then
      return format("%s near %d", comment_error, index), index
    end
    if end_ind > index then return "Comment", end_ind end
    return "Punctuator", scan_punctuator(input, index, features)
  elseif first == 91 then -- [
    local second = index < length and byte(input, index + 1) or -1
    if second == 91 or second == 61 then -- [ or =
      local end_ind, long_string_error = scan_long_string(input, index)
      if long_string_error ~= nil then
        return format("%s near %d", long_string_error, index), index
      end
      if end_ind > index then return "StringLiteral", end_ind end
    end
    return "Punctuator", scan_punctuator(input, index, features)
  elseif first == 34 or first == 39 then -- " or '
    local end_ind = scan_quote_string(input, index, false, features)
    if end_ind > index then return "StringLiteral", end_ind end
    return format("malformed string near %d", index), index
  else
    local end_ind = scan_punctuator(input, index, features)
    if end_ind > index then return "Punctuator", end_ind end
    return format("unknown token near %d", index), index
  end
end

local function scan_token_value(features, input, index)
  local length = #input
  if index > length then return "EOF", index end
  local first = byte(input, index)
  if is_whitespace(first) then
    index = skip_whitespaces(input, index + 1)
    if index > length then return "EOF", index end
    first = byte(input, index)
  end

  if first == 34 or first == 39 then -- " or '
    local end_ind, value = scan_quote_string(input, index, true, features)
    if end_ind > index then return "StringLiteral", end_ind, value end
    return format("malformed string near %d", index), index
  elseif first == 91 then -- [
    local end_ind, long_string_error = scan_long_string(input, index)
    if long_string_error ~= nil then
      return format("%s near %d", long_string_error, index), index
    end
    if end_ind > index then
      return "StringLiteral", end_ind, long_string_value(input, index, end_ind)
    end
  end

  local t, end_ind = scan_token(features, input, index)
  if not token_types[t] or t == "EOF" then return t, end_ind end

  local value = sub(input, index, end_ind - 1)
  if t == "NumberLiteral" then
    value = tonumber(value)
    if value == nil then
      return format("unsupported number value near %d", index), index
    end
  elseif t == "BooleanLiteral" then
    value = first == 116 -- true starts with "t"
  end
  return t, end_ind, value
end

local lexer_methods = {}
local lexer_mt = { __index = lexer_methods, __metatable = false }

local stateful_lexer_methods = {}
local stateful_lexer_mt = {
  __index = stateful_lexer_methods,
  __metatable = false,
}
--- Scan one token after any leading whitespace at the one-based byte `index`.
--- Returns its type and exclusive end index, or an error string and `index`.
--- Runs in O(k) time and O(1) auxiliary space, where k is the number of bytes
--- in the skipped whitespace and token.
function lexer_methods:scan_token(input, index)
  return scan_token(self._features, input, index)
end

--- Scan and decode one token after leading whitespace at the byte `index`.
--- Returns its type, exclusive end index, and value; lexical failures return
--- an error string and `index`. Runs in O(k) time and O(k) space for a decoded
--- string value, where k is the skipped whitespace and token length.
function lexer_methods:scan_token_value(input, index)
  return scan_token_value(self._features, input, index)
end

-- Count logical line breaks in the half-open range [start_ind, end_ind).
-- Lua treats CRLF and LFCR pairs as one line break.
local function advance_line(input, start_ind, end_ind, line)
  local index = start_ind
  while index < end_ind do
    local char = byte(input, index)
    if char == 10 or char == 13 then
      local next_char = byte(input, index + 1)
      if
        index + 1 < end_ind
        and (next_char == 10 or next_char == 13)
        and next_char ~= char
      then
        index = index + 1
      end
      line = line + 1
    end
    index = index + 1
  end
  return line
end

local function scan_token_info(features, input, index, line)
  local start_ind = index
  if start_ind <= #input and is_whitespace(byte(input, start_ind)) then
    start_ind = skip_whitespaces(input, start_ind + 1)
  end
  local token_line = advance_line(input, index, start_ind, line)

  local token_type, end_ind = scan_token(features, input, index)
  if not token_types[token_type] then error(token_type, 3) end

  if token_type == "EOF" then
    return {
      type = "EOF",
      raw = "",
      start = start_ind,
      finish = end_ind,
      line = token_line,
    }
  end

  local raw = sub(input, start_ind, end_ind - 1)
  local value = raw
  if token_type == "StringLiteral" then
    local first = byte(input, start_ind)
    if first == 34 or first == 39 then
      local value_end
      value_end, value = scan_quote_string(input, start_ind, true, features)
      if value_end == start_ind then
        error("malformed string near " .. start_ind, 3)
      end
    else
      value = long_string_value(input, start_ind, end_ind)
    end
  elseif token_type == "NumberLiteral" then
    value = tonumber(raw)
  elseif token_type == "BooleanLiteral" then
    value = byte(raw, 1) == 116
  elseif token_type == "NilLiteral" or token_type == "EOF" then
    value = nil
  end

  return {
    type = token_type,
    raw = raw,
    value = value,
    start = start_ind,
    finish = end_ind,
    line = token_line,
  }
end

local function stateful_scan(self)
  if self._cached_token ~= nil then return self._cached_token end
  local token =
    scan_token_info(self._features, self._input, self._index, self._line)
  self._cached_token = token
  return token
end

--- Return the next token without consuming it, raising on a lexical error.
--- The first call for a token takes O(k) time and O(k) output/cache space;
--- subsequent peeks of that token take O(1) time.
function stateful_lexer_methods:peek() return stateful_scan(self) end

--- Return and consume the next token, raising on a lexical error.
--- Runs in O(k) time and O(k) output space for the consumed source span.
function stateful_lexer_methods:next()
  local token = stateful_scan(self)
  self._line = advance_line(self._input, self._index, token.finish, self._line)
  self._index = token.finish
  if token.type ~= "EOF" then self._cached_token = nil end
  return token
end

--- Consume the next token only if its type equals `expected_type`.
--- A mismatch raises without consuming it. Complexity is the same as `next`.
function stateful_lexer_methods:typed_next(expected_type)
  local token = self:peek()
  if token.type ~= expected_type then
    error(
      format(
        "expected token type '%s', got '%s'",
        tostring(expected_type),
        token.type
      ),
      2
    )
  end
  return self:next()
end

--- Create a version-configured stateless lexer.
--- `options.lua_version` defaults to `"5.1"`. Runs in O(1) time and space.
local function new(options)
  options = options or {}
  local lua_version = options.lua_version or "5.1"
  local features = feature_profiles[lua_version]
  if features == nil then
    error(format("unsupported Lua version '%s'", tostring(lua_version)), 2)
  end
  return setmetatable(
    { lua_version = lua_version, _features = features },
    lexer_mt
  )
end

--- Create a stateful lexer over `input`, initially positioned at byte one.
--- `options.lua_version` defaults to `"5.1"`. Construction takes O(1) time
--- and space and retains a reference to the input string.
local function from_string(input, options)
  if type(input) ~= "string" then error("input must be a string", 2) end
  options = options or {}
  local lua_version = options.lua_version or "5.1"
  local features = feature_profiles[lua_version]
  if features == nil then
    error(format("unsupported Lua version '%s'", tostring(lua_version)), 2)
  end
  return setmetatable({
    lua_version = lua_version,
    _features = features,
    _input = input,
    _index = 1,
    _line = 1,
  }, stateful_lexer_mt)
end

return {
  token_types = token_types,
  new = new,
  from_string = from_string,
}
