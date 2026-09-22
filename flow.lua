local parser=require("moonsec.Lua.luaparse.parser")
local m={}
local fields=parser.node_fields

local function isname(x,n) return x and x.type=="Identifier" and x.name==n end

local function stop(x)
 return x.type=="BreakStatement" or x.type=="LabelStatement" or x.type=="GotoStatement"
end

local function num(x)
 if not x then return end
 if x.type=="NumberLiteral" then return x.value end
 if x.type=="UnaryExpression" and x.operator=="-" and x.argument.type=="NumberLiteral" then return -x.argument.value end
end

local function repl(body)
 local x=body[1]
 if not x or x.type~="IfStatement" then return end
 local a={}
 for _,q in ipairs(x.clauses[1].body) do if stop(q) then break end a[#a+1]=q end
 local b={}
 for i=2,#body do if stop(body[i]) then break end b[#b+1]=body[i] end
 return {type="IfStatement",clauses={{type="IfClause",condition=x.clauses[1].condition,body=a},{type="ElseClause",body=b}}}
end

local function statecond(x,n,name)
 if not x or x.type~="BinaryExpression" then return end
 local a,b
 if isname(x.left,name) and x.right.type=="NumberLiteral" then a=n b=x.right.value
 elseif isname(x.right,name) and x.left.type=="NumberLiteral" then a=x.left.value b=n
 else return end
 local q=x.operator
 if q=="==" then return a==b elseif q=="~=" then return a~=b elseif q=="<" then return a<b elseif q==">" then return a>b elseif q=="<=" then return a<=b elseif q==">=" then return a>=b end
end

local function leaf(x,n,name)
 if not x or x.type~="IfStatement" then return end
 for _,q in ipairs(x.clauses) do
  if q.type=="ElseClause" or statecond(q.condition,n,name) then
   local b=q.body
   if #b==1 and b[1].type=="IfStatement" and statecond(b[1].clauses[1].condition,n,name)~=nil then return leaf(b[1],n,name) end
   return b
  end
 end
end

local function maxnum(x,name)
 local n=0
 local function walk(q)
  if type(q)~="table" then return end
  if q.type=="BinaryExpression" and ((isname(q.left,name) and q.right.type=="NumberLiteral") or (isname(q.right,name) and q.left.type=="NumberLiteral")) then
   local v=q.left.type=="NumberLiteral" and q.left.value or q.right.value
   if v>n then n=v end
  end
  local fs=q.type and fields[q.type]
  if fs then for _,k in ipairs(fs) do local v=q[k] if type(v)=="table" then if v.type then walk(v) else for _,z in ipairs(v) do walk(z) end end end end end
 end
 walk(x)
 return math.floor(n)+2
end

local function machine(x)
 local tree
 local name
 local first
 local last
 if x.type=="NumericForStatement" and #x.body==1 and x.body[1].type=="IfStatement" then
  tree=x.body[1]
  name=x.variable.name
  first=math.floor(x.start.value or 0)
  last=math.floor(x.limit.value or maxnum(tree,name))
 elseif x.type=="WhileStatement" and x.body[1] and x.body[1].type=="IfStatement" and x.condition.type=="BinaryExpression" and x.condition.left.type=="Identifier" then
  tree=x.body[1]
  name=x.condition.left.name
  first=0
  last=maxnum(tree,name)
 else return end
 local out={}
 local seen={}
 for i=first,last do
  local b=leaf(tree,i,name)
  if b and not seen[b] then
   seen[b]=true
   for _,q in ipairs(b) do out[#out+1]=q end
  end
 end
 return out
end

local function one(x)
 local fs=x.type and fields[x.type]
 if fs then
  for _,k in ipairs(fs) do
   local v=x[k]
   if type(v)=="table" then
    if v.type then x[k]=one(v)
    else for i,q in ipairs(v) do v[i]=one(q) end end
   end
  end
 end
 if x.type=="RepeatStatement" and x.condition.type=="BooleanLiteral" and x.condition.value==true then return repl(x.body) or x end
 if x.type=="NumericForStatement" and x.body[1] and x.body[1].type=="IfStatement" then
  local tail=x.body[#x.body]
  local head=x.body[1].clauses[1].body
  local last=head[#head]
  if tail and (tail.type=="BreakStatement" or tail.type=="DoStatement") or last and (last.type=="BreakStatement" or last.type=="DoStatement") then
   local q=repl(x.body)
   if q then q._state={name=x.variable.name,first=num(x.start),last=num(x.limit),step=num(x.step) or 1} return q end
   return x
  end
 end
 if x.type=="IfStatement" then
  local b=x.clauses[1].body
  if b[1] and b[1].type=="IfStatement" and b[#b] and b[#b].type=="LabelStatement" then return repl(b) or x end
 end
 return x
end

local function blocks(x)
 local fs=x.type and fields[x.type]
 if fs then
  for _,k in ipairs(fs) do
   local v=x[k]
   if type(v)=="table" then
    if v.type then blocks(v)
    else
     local i=1
     while i<=#v do
      local a=machine(v[i])
      if a then
       table.remove(v,i)
       for q=#a,1,-1 do table.insert(v,i,a[q]) end
       i=i+#a
      else i=i+1 end
     end
     local cut
     for j,q in ipairs(v) do if q.type=="DoStatement" or q.type=="ReturnStatement" or q.type=="BreakStatement" then cut=j break end end
     if cut then while #v>cut do table.remove(v) end end
     for _,q in ipairs(v) do blocks(q) end
    end
   end
  end
 end
end

function m.run(x)
 x=one(x)
 blocks(x)
 return x
end

return m
