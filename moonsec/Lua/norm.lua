local parser=require("moonsec.Lua.luaparse.parser")
local m={}
local fields=parser.node_fields

local function rename(ast)
 local scopes={{}}
 local count=0
 local function push() scopes[#scopes+1]={} end
 local function pop() scopes[#scopes]=nil end
 local function use(n)
  for i=#scopes,1,-1 do
   local v=scopes[i][n.name]
   if v then n.name=v return end
  end
 end
 local function def(n)
  local v="_"..count
  count=count+1
  scopes[#scopes][n.name]=v
  n.name=v
 end
 local ex
 local block
 local function any(x)
  if type(x)~="table" then return end
  if x.type then ex(x) else for _,q in ipairs(x) do ex(q) end end
 end
 ex=function(x)
  if type(x)~="table" then return end
  local t=x.type
  if t=="Identifier" then use(x) return end
  if t=="FunctionDeclaration" then
   if x.identifier then
    if x.scope=="local" then def(x.identifier) else ex(x.identifier) end
   end
   push()
   for _,q in ipairs(x.parameters) do if q.type~="VarargParameter" then def(q) end end
   block(x.body)
   pop()
   return
  end
  if t=="VariableDeclaration" then
   for _,q in ipairs(x.init or {}) do ex(q) end
   for _,q in ipairs(x.variables) do def(q.identifier) end
   return
  end
  if t=="AssignmentStatement" then
   for _,q in ipairs(x.init) do ex(q) end
   for _,q in ipairs(x.variables) do ex(q) end
   return
  end
  if t=="NumericForStatement" then
   ex(x.start) ex(x.limit) if x.step then ex(x.step) end
   push() def(x.variable) block(x.body) pop()
   return
  end
  if t=="GenericForStatement" then
   for _,q in ipairs(x.iterators) do ex(q) end
   push() for _,q in ipairs(x.variables) do def(q) end block(x.body) pop()
   return
  end
  if t=="WhileStatement" then ex(x.condition) push() block(x.body) pop() return end
  if t=="RepeatStatement" then push() block(x.body) ex(x.condition) pop() return end
  if t=="DoStatement" then push() block(x.body) pop() return end
  if t=="IfStatement" then
   for _,q in ipairs(x.clauses) do
    if q.condition then ex(q.condition) end
    push() block(q.body) pop()
   end
   return
  end
  local fs=fields[t]
  if fs then
   for _,k in ipairs(fs) do
    if k~="identifier" or t~="MemberExpression" then any(x[k]) end
   end
  end
 end
 block=function(a) for _,x in ipairs(a) do ex(x) end end
 ex(ast)
 return ast
end

local function replace(ast,map)
 local function rep(x)
  if type(x)~="table" then return x end
  local fs=x.type and fields[x.type]
  if fs then
   for _,k in ipairs(fs) do
    local v=x[k]
    if type(v)=="table" then
     if v.type then x[k]=rep(v) else for i,q in ipairs(v) do v[i]=rep(q) end end
    end
   end
  end
  if x.type=="MemberExpression" and x.identifier and map[x.identifier.name] then
   local a=map[x.identifier.name]
   local n=tonumber(a[1])
   if n then return {type="NumberLiteral",value=n,raw=tostring(n)} end
   local y={type="Identifier",name=a[1]}
   for i=2,#a do y={type="MemberExpression",base=y,identifier={type="Identifier",name=a[i]},indexer="."} end
   return y
  end
  return x
 end
 return rep(ast)
end

local function ids(ast,map)
 local function walk(x)
  if type(x)~="table" then return end
  if x.type=="Identifier" and map[x.name] then x.name=map[x.name] end
  local fs=x.type and fields[x.type]
  if fs then for _,k in ipairs(fs) do local v=x[k] if type(v)=="table" then if v.type then walk(v) else for _,q in ipairs(v) do walk(q) end end end end end
 end
 walk(ast)
end

local function fold(ast)
 local function one(x)
  if type(x)~="table" then return x end
  local fs=x.type and fields[x.type]
  if fs then for _,k in ipairs(fs) do local v=x[k] if type(v)=="table" then if v.type then x[k]=one(v) else for i,q in ipairs(v) do v[i]=one(q) end end end end end
  if x.type=="UnaryExpression" and x.operator=="-" and x.argument.type=="NumberLiteral" then return {type="NumberLiteral",value=-x.argument.value,raw=tostring(-x.argument.value)} end
  if x.type=="BinaryExpression" and x.left.type=="NumberLiteral" and x.right.type~="NumberLiteral" then
   local q={['<']='>',['>']='<',['<=']='>=',['>=']='<='}
   if x.operator=="==" or x.operator=="~=" or q[x.operator] then x.left,x.right=x.right,x.left x.operator=q[x.operator] or x.operator end
  end
  return x
 end
 return one(ast)
end

function m.run(ast,pools)
 rename(ast)
 local map={}
 for _,p in ipairs(pools or {}) do for k,v in pairs(p) do map[k]=v end end
 replace(ast,map)
 fold(ast)
 return ast
end

m.ids=ids
return m
