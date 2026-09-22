local lexer = require("moonsec.Lua.luaparse.lexer")
local format = string.format
local table_remove = table.remove
local error = error
local setmetatable = setmetatable
local type = type
local tostring = tostring

-- FOLLOW(block) is {end, else, elseif, until, EOF}
local function is_block_follow(token)
  if token.type == "Keyword" then
    local raw = token.raw
    return raw == "end" or raw == "else" or raw == "elseif" or raw == "until"
  end
  return token.type == "EOF"
end

local function node(node_type, fields)
  fields = fields or {}
  fields.type = node_type
  return fields
end

local function syntax_error(token, message)
  error(format("%s near byte %d", message, token.start), 0)
end

local parser_methods = {}
local parser_mt = { __index = parser_methods, __metatable = false }

-- read tokens until the next non-comment token, retaining every token in source
-- order and anchoring skipped comments to their neighboring significant tokens
function parser_methods:read_significant()
  while true do
    local token = self.scanner:next()
    local token_index = #self.tokens + 1
    self.tokens[token_index] = token
    if token.type ~= "Comment" then
      if token.type ~= "EOF" then
        local pending_comments = self.pending_comments
        local pending_count = #pending_comments
        if pending_count ~= 0 then
          for i = 1, pending_count do
            pending_comments[i].next_token = token_index
          end
          self.pending_comments = {}
        end
        self.previous_significant = token_index
      end
      return token
    end

    local raw = token.raw
    local comment = node("Comment", {
      raw = raw,
      -- the pattern is lua version of '^--\[=*\[',
      -- which is beginning of a multiline comment
      multiline = raw:find("^%-%-%[=*%[") ~= nil,
      previous_token = self.previous_significant,
    })
    self.comments[#self.comments + 1] = comment
    self.pending_comments[#self.pending_comments + 1] = comment
  end
end

function parser_methods:peek(offset)
  offset = offset or 1
  while #self.lookahead < offset do
    self.lookahead[#self.lookahead + 1] = self:read_significant()
  end
  return self.lookahead[offset]
end

function parser_methods:next()
  local token = self:peek()
  table_remove(self.lookahead, 1)
  self.last_consumed = token
  return token
end

function parser_methods:is_token(token_type, value)
  local token = self:peek()
  return token.type == token_type and (value == nil or token.raw == value)
end

-- consume the current token and return true when its type and optional raw
-- value match; otherwise leave the token unconsumed and return false
function parser_methods:consume(token_type, value)
  if not self:is_token(token_type, value) then return false end
  self:next()
  return true
end

-- consume and return a required token, raising a syntax error at the current
-- token without consuming it when its type or optional raw value does not match
function parser_methods:expect(token_type, value)
  local token = self:peek()
  if token.type ~= token_type or (value ~= nil and token.raw ~= value) then
    local expected = value and format("'%s'", value)
      or format("token type '%s'", token_type)
    syntax_error(token, format("expected %s, got '%s'", expected, token.raw))
  end
  return self:next()
end

function parser_methods:expect_identifier()
  local token = self:expect("Identifier")
  return node("Identifier", { name = token.raw, line = token.line })
end

-- expression parsing methods

-- explist ::= {exp ','} exp
function parser_methods:parse_expression_list()
  local expressions = { self:parse_expression() }
  while self:consume("Punctuator", ",") do
    expressions[#expressions + 1] = self:parse_expression()
  end
  return expressions
end

function parser_methods:has_line_break_before(token)
  local previous = self.last_consumed
  if previous == nil then return false end

  -- Token ranges are one-based and half-open. Check the source gap between
  -- the previously consumed token and the token about to be consumed.
  for i = previous.finish, token.start - 1 do
    local char = self.source:byte(i)
    if char == 10 or char == 13 then return true end
  end
  return false
end

-- args ::= '(' [explist] ')' | tableconstructor | String
function parser_methods:parse_arguments()
  if self:is_token("Punctuator", "(") then
    local opening = self:peek()
    if
      self.features.reject_newline_before_call_parenthesis
      and self:has_line_break_before(opening)
    then
      syntax_error(opening, "ambiguous syntax (function call or new statement)")
    end
    self:next()

    local arguments = {}
    if not self:is_token("Punctuator", ")") then
      arguments = self:parse_expression_list()
    end
    self:expect("Punctuator", ")")
    return arguments
  elseif self:is_token("Punctuator", "{") then
    return { self:parse_table() }
  elseif self:is_token("StringLiteral") then
    local token = self:next()
    return { node("StringLiteral", { raw = token.raw, value = token.value }) }
  end
  syntax_error(self:peek(), "expected function arguments")
end

local function is_arguments_begin(token)
  local token_type = token.type
  local raw = token.raw
  return token_type == "StringLiteral"
    or token_type == "Punctuator" and (raw == "(" or raw == "{")
end

-- prefixexp ::= var | functioncall | '(' exp ')'
-- var ::= Name | prefixexp '[' exp ']' | prefixexp '.' Name
-- functioncall ::= prefixexp args | prefixexp ':' Name args
--
-- after substituting var and functioncall:
-- prefixexp ::= Name
--             | '(' exp ')'
--             | prefixexp '[' exp ']'
--             | prefixexp '.' Name
--             | prefixexp args
--             | prefixexp ':' Name args
--
-- after eliminating direct left recursion:
-- prefixexp ::= (Name | '(' exp ')') {suffixexp}
-- suffixexp ::= '[' exp ']' | '.' Name | args | ':' Name args
function parser_methods:parse_prefix_expression()
  local base
  if self:is_token("Identifier") then
    base = self:expect_identifier()
  elseif self:consume("Punctuator", "(") then
    local expression = self:parse_expression()
    base = node("ParenthesizedExpression", { expression = expression })
    self:expect("Punctuator", ")")
  else
    syntax_error(self:peek(), "expected prefix expression")
  end

  -- suffixes
  while true do
    if self:consume("Punctuator", "[") then
      local index = self:parse_expression()
      self:expect("Punctuator", "]")
      base = node("IndexExpression", { base = base, index = index })
    elseif self:consume("Punctuator", ".") then
      local name = self:expect_identifier()
      base = node(
        "MemberExpression",
        { base = base, identifier = name, indexer = "." }
      )
    elseif self:consume("Punctuator", ":") then
      local name = self:expect_identifier()
      local member = node(
        "MemberExpression",
        { base = base, identifier = name, indexer = ":" }
      )
      local arguments = self:parse_arguments()
      base = node("CallExpression", { base = member, arguments = arguments })
    elseif is_arguments_begin(self:peek()) then
      local arguments = self:parse_arguments()
      base = node("CallExpression", { base = base, arguments = arguments })
    else
      return base
    end
  end
end

-- tableconstructor ::= '{' [fieldlist] '}'
-- fieldlist ::= field {fieldsep field} [fieldsep]
-- field ::= '[' exp ']' '=' exp | Name '=' exp | exp
-- fieldsep ::= ',' | ';'
function parser_methods:parse_table()
  self:expect("Punctuator", "{")
  local fields = {}
  while not self:is_token("Punctuator", "}") do
    local field
    if self:consume("Punctuator", "[") then
      -- field ::= '[' exp ']' '=' exp
      local key = self:parse_expression()
      self:expect("Punctuator", "]")
      self:expect("Punctuator", "=")
      local value = self:parse_expression()
      field = node("TableKey", { key = key, value = value })
    else
      -- field ::= Name '=' exp | exp
      -- because '=' is not in follow set of `field`,
      -- seeing a '=' unambiguously selects Name '=' exp
      local expression = self:parse_expression()
      if self:consume("Punctuator", "=") then
        if expression.type ~= "Identifier" then
          syntax_error(self:peek(), "expected identifier table key")
        end
        local value = self:parse_expression()
        field = node("TableKeyString", { key = expression, value = value })
      else
        field = node("TableValue", { value = expression })
      end
    end
    fields[#fields + 1] = field
    if
      not self:consume("Punctuator", ",")
      and not self:consume("Punctuator", ";")
    then
      break
    end
  end
  self:expect("Punctuator", "}")
  return node("TableConstructorExpression", { fields = fields })
end

-- funcbody ::= '(' [parlist] ')' block end
-- parlist ::= namelist [',' varargparam] | varargparam
-- varargparam ::= '...' [Name]
function parser_methods:parse_function_body(identifier, scope)
  self:expect("Punctuator", "(")
  local parameters = {}
  if not self:is_token("Punctuator", ")") then
    repeat
      if self:consume("VarargLiteral") then
        local line = self.last_consumed.line
        local vararg_name
        if self.features.named_varargs and self:is_token("Identifier") then
          vararg_name = self:expect_identifier()
        end
        parameters[#parameters + 1] =
          node("VarargParameter", { identifier = vararg_name, line = line })
        break
      end
      parameters[#parameters + 1] = self:expect_identifier()
    until not self:consume("Punctuator", ",")
  end
  self:expect("Punctuator", ")")

  local body = self:parse_block()
  self:expect("Keyword", "end")
  return node("FunctionDeclaration", {
    identifier = identifier,
    scope = scope,
    parameters = parameters,
    body = body,
  })
end

-- Atomic and prefix expression portion of:
-- exp ::= nil | false | true | Number | String | '...' | function |
--         prefixexp | tableconstructor | exp binop exp | unop exp
-- function ::= function funcbody
-- prefixexp ::= var | functioncall | '(' exp ')'
function parser_methods:parse_primary()
  local token = self:peek()
  local token_type = token.type
  if token_type == "NilLiteral" then
    self:next()
    return node("NilLiteral", { raw = token.raw })
  elseif token_type == "BooleanLiteral" then
    self:next()
    return node("BooleanLiteral", { raw = token.raw, value = token.value })
  elseif token_type == "NumberLiteral" then
    self:next()
    return node("NumberLiteral", { raw = token.raw, value = token.value })
  elseif token_type == "StringLiteral" then
    self:next()
    return node("StringLiteral", { raw = token.raw, value = token.value })
  elseif token_type == "VarargLiteral" then
    self:next()
    return node("VarargLiteral", { raw = token.raw, line = token.line })
  elseif self:is_token("Punctuator", "{") then
    return self:parse_table()
  elseif self:consume("Keyword", "function") then
    return self:parse_function_body(nil, nil)
  else
    return self:parse_prefix_expression()
  end
end

-- used in parse_subexpression, put in module scope to avoid recreating
local binary_precedence = {
  ["or"] = 1,
  ["and"] = 2,

  ["<"] = 3,
  [">"] = 3,
  ["<="] = 3,
  [">="] = 3,
  ["~="] = 3,
  ["=="] = 3,

  ["|"] = 4,
  ["~"] = 5,
  ["&"] = 6,
  ["<<"] = 7,
  [">>"] = 7,

  [".."] = 8,

  ["+"] = 9,
  ["-"] = 9,

  ["*"] = 10,
  ["/"] = 10,
  ["//"] = 10,
  ["%"] = 10,
  -- precedence 11 is reserved for unary operators, below exponentiation "^"
  ["^"] = 12,
}
local right_associative = { ["^"] = true, [".."] = true }
local unary_operators = {
  ["-"] = true,
  ["#"] = true,
  ["not"] = true,
  ["~"] = true,
}

-- Precedence-aware implementation of:
-- exp ::= exp binop exp | unop exp
function parser_methods:parse_subexpression(minimum_precedence)
  local operator = self:peek().raw
  local left
  if unary_operators[operator] then
    self:next()
    -- Unary precedence is below exponentiation, so -2^2 parses as -(2^2).
    local argument = self:parse_subexpression(11)
    left = node("UnaryExpression", { operator = operator, argument = argument })
  else
    left = self:parse_primary()
  end

  while true do
    operator = self:peek().raw
    local precedence = binary_precedence[operator]
    -- stop combining if the next token is not a binary operator
    -- or its precedence is below the required minimum
    if precedence == nil or precedence < minimum_precedence then break end
    self:next()
    -- keep the same minimum for right-associative operators so an operator of
    -- equal precedence can be included in the right operand; increase it for
    -- left-associative operators to exclude equal precedence
    if not right_associative[operator] then precedence = precedence + 1 end
    local right = self:parse_subexpression(precedence)
    left = node(
      (operator == "and" or operator == "or") and "LogicalExpression"
        or "BinaryExpression",
      { operator = operator, left = left, right = right }
    )
  end
  return left
end

-- exp ::= nil | false | true | Number | String | '...' | function |
--         prefixexp | tableconstructor | exp binop exp | unop exp
function parser_methods:parse_expression() return self:parse_subexpression(1) end

-- end of expression parsing methods

local function is_assignable(expression)
  local expr_type = expression.type
  return expr_type == "Identifier"
    or expr_type == "MemberExpression"
    or expr_type == "IndexExpression"
end

-- attrib ::= '<' Name '>'
-- because attrib is always optional, return nil if next token is not '<'
function parser_methods:parse_attribute()
  if not self:is_token("Punctuator", "<") then return nil end
  local line = self:next().line
  local name = self:expect_identifier()
  self:expect("Punctuator", ">")
  return node("Attribute", { name = name.name, line = line })
end

-- declaratorlist ::= Name [attrib] {',' Name [attrib]}
function parser_methods:parse_declarator_list()
  local variables = {}
  local allow_attr = self.features.variable_attributes
  repeat
    local identifier = self:expect_identifier()
    local attribute
    if allow_attr then attribute = self:parse_attribute() end
    variables[#variables + 1] = node("VariableDeclarator", {
      identifier = identifier,
      attribute = attribute,
    })
  until not self:consume("Punctuator", ",")
  return variables
end

-- Lua 5.4: attnamelist ::= declaratorlist
-- Lua 5.5: attnamelist ::= [attrib] declaratorlist
function parser_methods:parse_declarators()
  local attribute
  if self.features.attribute_prefix then attribute = self:parse_attribute() end
  return attribute, self:parse_declarator_list()
end

function parser_methods:is_contextual_goto()
  if self:is_token("Identifier", "goto") and self.features.contextual_goto then
    local label = self:peek(2)
    return label.type == "Identifier" and label.raw ~= "goto"
  end
  return false
end

-- statement parsing methods

-- stat ::= ';'
--        | varlist '=' explist
--        | functioncall
--        | label
--        | break
--        | goto Name
--        | do block end
--        | while exp do block end
--        | repeat block until exp
--        | if exp then block {elseif exp then block} [else block] end
--        | for Name '=' exp ',' exp [',' exp] do block end
--        | for namelist in explist do block end
--        | function funcname funcbody
--        | local function Name funcbody
--        | global function Name funcbody
--        | local attnamelist ['=' explist]
--        | global attnamelist ['=' explist]
--        | global [attrib] '*'
-- label ::= '::' Name '::'
function parser_methods:parse_statement()
  if self.features.empty_statements and self:consume("Punctuator", ";") then
    return node("EmptyStatement")
  elseif self:is_token("Punctuator", "::") then
    local line = self:next().line
    local label = self:expect_identifier()
    self:expect("Punctuator", "::")
    return node("LabelStatement", { label = label, line = line })
  -- stat ::= goto Name
  elseif self:is_token("Keyword", "goto") or self:is_contextual_goto() then
    local line = self:next().line
    local label = self:expect_identifier()
    return node("GotoStatement", { label = label, line = line })
  -- do block end
  elseif self:consume("Keyword", "do") then
    local body = self:parse_block()
    self:expect("Keyword", "end")
    return node("DoStatement", { body = body })
  -- while exp do block end
  elseif self:consume("Keyword", "while") then
    local condition = self:parse_expression()
    self:expect("Keyword", "do")
    local body = self:parse_block()
    self:expect("Keyword", "end")
    return node("WhileStatement", { condition = condition, body = body })
  -- repeat block until exp
  elseif self:consume("Keyword", "repeat") then
    local body = self:parse_block()
    self:expect("Keyword", "until")
    local condition = self:parse_expression()
    return node("RepeatStatement", { body = body, condition = condition })
  elseif self:consume("Keyword", "if") then
    return self:parse_if()
  elseif self:consume("Keyword", "for") then
    return self:parse_for()
  -- function funcname funcbody
  elseif self:consume("Keyword", "function") then
    local identifier = self:parse_function_name()
    return self:parse_function_body(identifier, nil)
  elseif self:consume("Keyword", "local") then
    return self:parse_local()
  elseif self:consume("Keyword", "global") then
    return self:parse_global()
  elseif self:is_token("Keyword", "break") then
    local line = self:next().line
    return node("BreakStatement", { line = line })
  end
  return self:parse_assignment_or_call()
end

-- funcname ::= Name {'.' Name} [':' Name]
function parser_methods:parse_function_name()
  local expression = self:expect_identifier()
  while self:consume("Punctuator", ".") do
    local name = self:expect_identifier()
    expression = node(
      "MemberExpression",
      { base = expression, identifier = name, indexer = "." }
    )
  end
  if self:consume("Punctuator", ":") then
    local method = self:expect_identifier()
    expression = node(
      "MemberExpression",
      { base = expression, identifier = method, indexer = ":" }
    )
  end
  return expression
end

-- stat ::= if exp then block {elseif exp then block} [else block] end
function parser_methods:parse_if()
  local condition = self:parse_expression()
  self:expect("Keyword", "then")
  local body = self:parse_block()
  local clauses = { node("IfClause", { condition = condition, body = body }) }
  while self:consume("Keyword", "elseif") do
    condition = self:parse_expression()
    self:expect("Keyword", "then")
    body = self:parse_block()
    clauses[#clauses + 1] =
      node("ElseifClause", { condition = condition, body = body })
  end
  if self:consume("Keyword", "else") then
    body = self:parse_block()
    clauses[#clauses + 1] = node("ElseClause", { body = body })
  end
  self:expect("Keyword", "end")
  return node("IfStatement", { clauses = clauses })
end

-- invoke after the `for` is already consumed
function parser_methods:parse_for()
  local variable = self:expect_identifier()
  -- stat ::= for Name '=' exp ',' exp [',' exp] do block end
  if self:consume("Punctuator", "=") then
    local start = self:parse_expression()
    self:expect("Punctuator", ",")
    local limit = self:parse_expression()
    local step
    if self:consume("Punctuator", ",") then step = self:parse_expression() end
    self:expect("Keyword", "do")
    local body = self:parse_block()
    self:expect("Keyword", "end")
    return node("NumericForStatement", {
      variable = variable,
      start = start,
      limit = limit,
      step = step,
      body = body,
    })
  end

  -- stat ::= for namelist in explist do block end
  local variables = { variable }
  while self:consume("Punctuator", ",") do
    variables[#variables + 1] = self:expect_identifier()
  end
  self:expect("Keyword", "in")
  local iterators = self:parse_expression_list()
  self:expect("Keyword", "do")
  local body = self:parse_block()
  self:expect("Keyword", "end")
  return node("GenericForStatement", {
    variables = variables,
    iterators = iterators,
    body = body,
  })
end

-- stat ::= local function Name funcbody
--        | local attnamelist ['=' explist]
-- Invoked after the `local` is already consumed.
function parser_methods:parse_local()
  if self:consume("Keyword", "function") then
    local identifier = self:expect_identifier()
    return self:parse_function_body(identifier, "local")
  end

  local attribute, variables = self:parse_declarators()
  local init = {}
  if self:consume("Punctuator", "=") then
    init = self:parse_expression_list()
  end
  return node("VariableDeclaration", {
    scope = "local",
    attribute = attribute,
    variables = variables,
    init = init,
  })
end

-- stat ::= global function Name funcbody
--        | global attnamelist ['=' explist]
--        | global [attrib] '*'
-- Invoked after the `global` is already consumed.
function parser_methods:parse_global()
  if self:consume("Keyword", "function") then
    local identifier = self:expect_identifier()
    return self:parse_function_body(identifier, "global")
  end

  local attribute = self:parse_attribute()
  if self:consume("Punctuator", "*") then
    return node("GlobalWildcardDeclaration", { attribute = attribute })
  end

  local variables = self:parse_declarator_list()
  local init = self:consume("Punctuator", "=") and self:parse_expression_list()
    or {}
  return node("VariableDeclaration", {
    scope = "global",
    attribute = attribute,
    variables = variables,
    init = init,
  })
end

-- stat ::= varlist '=' explist | functioncall
-- varlist ::= var {',' var}
function parser_methods:parse_assignment_or_call()
  local expression = self:parse_prefix_expression()
  -- return early here because functioncall is never assignable,
  -- if there is a ',' or '=' later, it will be caught in caller
  if expression.type == "CallExpression" then
    return node("FunctionCallStatement", { expression = expression })
  end

  local variables = {}
  while true do
    if not is_assignable(expression) then
      syntax_error(self:peek(), "invalid assignment target")
    end
    variables[#variables + 1] = expression
    if not self:consume("Punctuator", ",") then break end
    expression = self:parse_prefix_expression()
  end
  self:expect("Punctuator", "=")
  local init = self:parse_expression_list()
  return node("AssignmentStatement", { variables = variables, init = init })
end

-- Lua 5.1: block ::= {stat [';']} [laststat [';']]
--          laststat ::= return [explist] | break
-- Lua 5.2+: block ::= {stat} [retstat]
--           retstat ::= return [explist] [';']
function parser_methods:parse_block()
  local body = {}
  local final_statement = false
  local allow_empty = self.features.empty_statements
  local break_must_be_last = self.features.break_must_be_last
  while true do
    local token = self:peek()
    if is_block_follow(token) then break end
    if final_statement then
      syntax_error(token, "statement must be last in its block")
    end

    if self:consume("Keyword", "return") then
      local empty_return = is_block_follow(self:peek())
        or self:is_token("Punctuator", ";")
      local arguments = empty_return and {} or self:parse_expression_list()
      body[#body + 1] = node("ReturnStatement", { arguments = arguments })
      final_statement = true
      self:consume("Punctuator", ";")
    else
      local statement = self:parse_statement()
      body[#body + 1] = statement
      -- Lua 5.1 treats both return and break as final statements. Later
      -- profiles keep return final but allow break among ordinary statements.
      if break_must_be_last and statement.type == "BreakStatement" then
        final_statement = true
      end
      if not allow_empty then self:consume("Punctuator", ";") end
    end
  end
  return body
end

-- end of statement parsing methods

local feature_profiles = {
  ["5.1"] = {
    break_must_be_last = true,
    reject_newline_before_call_parenthesis = true,
  },
  ["LuaJIT"] = {
    contextual_goto = true,
    break_must_be_last = true,
    reject_newline_before_call_parenthesis = true,
  },
  ["5.2"] = {
    empty_statements = true,
  },
  ["5.3"] = {
    empty_statements = true,
  },
  ["5.4"] = {
    empty_statements = true,
    variable_attributes = true,
  },
  ["5.5"] = {
    empty_statements = true,
    variable_attributes = true,
    attribute_prefix = true,
    named_varargs = true,
  },
}

local function new_parser(source, options)
  options = options or {}
  local lua_version = options.lua_version or "5.1"
  local features = feature_profiles[lua_version]
  if features == nil then
    error(format("unsupported Lua version '%s'", tostring(lua_version)), 3)
  end
  return setmetatable({
    source = source,
    scanner = lexer.from_string(source, { lua_version = lua_version }),
    features = features,
    tokens = {},
    comments = {},
    pending_comments = {},
    lookahead = {},
  }, parser_mt)
end

--- Parse `source` using `options.lua_version`, which defaults to `"5.1"`.
--- Returns `{ ast = chunk, tokens = tokens }` and raises on lexical or syntax
--- errors. For n source bytes, parsing takes O(n) time and O(n) space; the
--- recursive parser uses O(h) stack space for syntactic nesting depth h.
local function parse(source, options)
  if type(source) ~= "string" then error("source must be a string", 2) end
  local state = new_parser(source, options)
  local body = state:parse_block()
  state:expect("EOF")
  local ast = node("Chunk", { body = body, comments = state.comments })
  return { ast = ast, tokens = state.tokens }
end

-- Public map from AST node type to all fields that type can contain across the
-- supported profiles. Callers should treat this exported table as read-only.
-- Fields whose values are nil are absent from actual nodes. Only nodes used as
-- semantic diagnostic anchors currently have a line field.
local node_fields = {
  ["Chunk"] = { "body", "comments" },
  ["BreakStatement"] = { "line" },
  ["ReturnStatement"] = { "arguments" },
  ["IfStatement"] = { "clauses" },
  ["WhileStatement"] = { "condition", "body" },
  ["DoStatement"] = { "body" },
  ["RepeatStatement"] = { "body", "condition" },
  ["VariableDeclaration"] = { "scope", "attribute", "variables", "init" },
  ["GlobalWildcardDeclaration"] = { "attribute" },
  ["AssignmentStatement"] = { "variables", "init" },
  ["FunctionCallStatement"] = { "expression" },
  ["FunctionDeclaration"] = { "identifier", "scope", "parameters", "body" },
  ["NumericForStatement"] = { "variable", "start", "limit", "step", "body" },
  ["GenericForStatement"] = { "variables", "iterators", "body" },
  ["GotoStatement"] = { "label", "line" },
  ["LabelStatement"] = { "label", "line" },
  ["EmptyStatement"] = {},
  ["IfClause"] = { "condition", "body" },
  ["ElseifClause"] = { "condition", "body" },
  ["ElseClause"] = { "body" },
  ["VariableDeclarator"] = { "identifier", "attribute" },
  ["Attribute"] = { "name", "line" },
  ["VarargParameter"] = { "identifier", "line" },
  ["NilLiteral"] = { "raw" },
  ["BooleanLiteral"] = { "raw", "value" },
  ["NumberLiteral"] = { "raw", "value" },
  ["StringLiteral"] = { "raw", "value" },
  ["VarargLiteral"] = { "raw", "line" },
  ["Identifier"] = { "name", "line" },
  ["TableConstructorExpression"] = { "fields" },
  ["BinaryExpression"] = { "operator", "left", "right" },
  ["LogicalExpression"] = { "operator", "left", "right" },
  ["UnaryExpression"] = { "operator", "argument" },
  ["ParenthesizedExpression"] = { "expression" },
  ["MemberExpression"] = { "base", "identifier", "indexer" },
  ["IndexExpression"] = { "base", "index" },
  ["CallExpression"] = { "base", "arguments" },
  ["TableKey"] = { "key", "value" },
  ["TableKeyString"] = { "key", "value" },
  ["TableValue"] = { "value" },
  ["Comment"] = { "raw", "multiline", "previous_token", "next_token" },
}

return {
  node_fields = node_fields,
  parse = parse,
}
