local m={}

local function env(parent)
 return {v={},p=parent}
end

local function get(e,n)
 local q=e
 while q do
  if q.v[n]~=nil then return q.v[n] end
  q=q.p
 end
end

local function owner(e,n)
 local q=e
 while q do
  if q.v[n]~=nil then return q end
  q=q.p
 end
 return e
end

local function truth(v) return v~=false and v~=nil end

function m.run(x,limit)
 local left=limit or 2000000
 local depth=0
 local ex
 local block
 local function tick()
  left=left-1
  if left<0 then error("key expression step limit") end
 end
 local function call(f,a)
  tick()
  if type(f)=="function" then return {f(unpack(a))} end
  if type(f)~="table" or not f.body then error("unsafe key expression call") end
  depth=depth+1
  if depth>2048 then error("key expression depth limit") end
  local e=env(f.env)
  for i,p in ipairs(f.params) do
   if p.type=="VarargParameter" then
    local v={}
    for q=i,#a do v[#v+1]=a[q] end
    e.v["..."]=v
   else
    e.v[p.name or p.identifier and p.identifier.name]=a[i]
   end
  end
  local r=block(f.body,e)
  depth=depth-1
  return r and r.vals or {}
 end
 local function one(v) return type(v)=="table" and v.multi and v[1] or v end
 ex=function(n,e)
  tick()
  local t=n.type
  if t=="NumberLiteral" or t=="StringLiteral" or t=="BooleanLiteral" then return n.value end
  if t=="NilLiteral" then return nil end
  if t=="Identifier" then return get(e,n.name) end
  if t=="ParenthesizedExpression" then return one(ex(n.expression,e)) end
  if t=="UnaryExpression" then
   local v=one(ex(n.argument,e))
   if n.operator=="-" then return -v end
   if n.operator=="not" then return not truth(v) end
   if n.operator=="#" then return #v end
  end
  if t=="BinaryExpression" or t=="LogicalExpression" then
   local a=one(ex(n.left,e))
   if n.operator=="and" then return truth(a) and ex(n.right,e) or a end
   if n.operator=="or" then return truth(a) and a or ex(n.right,e) end
   local b=one(ex(n.right,e))
   local op=n.operator
   if op=="+" then return a+b elseif op=="-" then return a-b elseif op=="*" then return a*b elseif op=="/" then return a/b elseif op=="%" then return a%b elseif op=="^" then return a^b elseif op==".." then return tostring(a)..tostring(b) elseif op=="==" then return a==b elseif op=="~=" then return a~=b elseif op=="<" then return a<b elseif op==">" then return a>b elseif op=="<=" then return a<=b elseif op==">=" then return a>=b end
  end
  if t=="FunctionDeclaration" then return {body=n.body,params=n.parameters,env=e} end
  if t=="CallExpression" then
   local f=one(ex(n.base,e))
   local a={}
   for i,q in ipairs(n.arguments) do
    local v=ex(q,e)
    if i==#n.arguments and type(v)=="table" and v.multi then for _,z in ipairs(v) do a[#a+1]=z end else a[#a+1]=one(v) end
   end
   local r=call(f,a)
   r.multi=true
   return r
  end
  if t=="TableConstructorExpression" then
   local a={}
   local at=1
   for _,q in ipairs(n.fields) do
    if q.type=="TableValue" then a[at]=one(ex(q.value,e)) at=at+1
    elseif q.type=="TableKey" then a[one(ex(q.key,e))]=one(ex(q.value,e))
    elseif q.type=="TableKeyString" then a[q.key.name]=one(ex(q.value,e)) end
   end
   return a
  end
  if t=="IndexExpression" then return one(ex(n.base,e))[one(ex(n.index,e))] end
  if t=="MemberExpression" then return one(ex(n.base,e))[n.identifier.name] end
  if t=="VarargLiteral" then local a=get(e,"...") or {} a.multi=true return a end
  error("unsupported key expression "..tostring(t))
 end
 local function set(n,v,e)
  if n.type=="Identifier" then owner(e,n.name).v[n.name]=v
  elseif n.type=="IndexExpression" then one(ex(n.base,e))[one(ex(n.index,e))]=v
  elseif n.type=="MemberExpression" then one(ex(n.base,e))[n.identifier.name]=v
  else error("unsupported key assignment") end
 end
 local function stat(s,e)
  tick()
  local t=s.type
  if t=="VariableDeclaration" then
   local vals={}
   for i,q in ipairs(s.init or {}) do
    local v=ex(q,e)
    if i==#s.init and type(v)=="table" and v.multi then for _,z in ipairs(v) do vals[#vals+1]=z end else vals[#vals+1]=one(v) end
   end
   for i,q in ipairs(s.variables) do e.v[q.identifier.name]=vals[i] end
  elseif t=="AssignmentStatement" then
   local vals={}
   for i,q in ipairs(s.init) do
    local v=ex(q,e)
    if i==#s.init and type(v)=="table" and v.multi then for _,z in ipairs(v) do vals[#vals+1]=z end else vals[#vals+1]=one(v) end
   end
   for i,q in ipairs(s.variables) do set(q,vals[i],e) end
  elseif t=="FunctionDeclaration" then
   local f={body=s.body,params=s.parameters,env=e}
   if s.identifier then e.v[s.identifier.name]=f end
  elseif t=="FunctionCallStatement" then ex(s.expression,e)
  elseif t=="ReturnStatement" then
   local vals={}
   for i,q in ipairs(s.arguments) do
    local v=ex(q,e)
    if i==#s.arguments and type(v)=="table" and v.multi then for _,z in ipairs(v) do vals[#vals+1]=z end else vals[#vals+1]=one(v) end
   end
   return {kind="return",vals=vals}
  elseif t=="IfStatement" then
   for _,q in ipairs(s.clauses) do
    if q.type=="ElseClause" or truth(one(ex(q.condition,e))) then
     local r=block(q.body,env(e))
     if r then return r end
     break
    end
   end
  elseif t=="WhileStatement" then
   while truth(one(ex(s.condition,e))) do local r=block(s.body,env(e)) if r then if r.kind=="break" then break else return r end end end
  elseif t=="RepeatStatement" then
   repeat local q=env(e) local r=block(s.body,q) if r then if r.kind=="break" then break else return r end end until truth(one(ex(s.condition,q)))
  elseif t=="NumericForStatement" then
   local a=one(ex(s.start,e))
   local b=one(ex(s.limit,e))
   local d=s.step and one(ex(s.step,e)) or 1
   for i=a,b,d do local q=env(e) q.v[s.variable.name]=i local r=block(s.body,q) if r then if r.kind=="break" then break else return r end end end
  elseif t=="DoStatement" then
   local r=block(s.body,env(e))
   if r then return r end
  elseif t=="BreakStatement" then return {kind="break"}
  elseif t~="EmptyStatement" then error("unsupported key statement "..tostring(t)) end
 end
 block=function(a,e)
  for _,s in ipairs(a) do local r=stat(s,e) if r then return r end end
 end
 local e=env()
 local v=ex(x,e)
 return one(v)
end

return m
