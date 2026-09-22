local parser=require("moonsec.Lua.luaparse.parser")
local ops=require("moonsec.Lua.ops")
local flow=require("moonsec.Lua.flow")
local wraps=require("moonsec.Lua.wraps")
local m={}
local fields=parser.node_fields

local function isname(x,n) return x and x.type=="Identifier" and x.name==n end

local function enumcond(x)
 return x and x.type=="BinaryExpression" and ((isname(x.left,"enum") and x.right.type=="NumberLiteral") or (isname(x.right,"enum") and x.left.type=="NumberLiteral"))
end

local function val(x,n)
 if x.type=="NumberLiteral" then return x.value end
 if isname(x,"enum") then return n end
 error("invalid dispatch condition")
end

local function cond(x,n)
 local a,b=val(x.left,n),val(x.right,n)
 local q=x.operator
 if q=="==" then return a==b elseif q=="~=" then return a~=b elseif q=="<" then return a<b elseif q==">" then return a>b elseif q=="<=" then return a<=b elseif q==">=" then return a>=b end
end

local function find(x)
 if type(x)~="table" then return end
 if x.type=="IfStatement" and enumcond(x.clauses[1].condition) then return x end
 local fs=x.type and fields[x.type]
 if fs then
  for _,k in ipairs(fs) do
   local v=x[k]
   if type(v)=="table" then
    if v.type then local q=find(v) if q then return q end
    else for _,z in ipairs(v) do local q=find(z) if q then return q end end end
   end
  end
 end
end

local function leaf(x,n)
 for _,q in ipairs(x.clauses) do
  if q.type=="ElseClause" or cond(q.condition,n) then
   local b=q.body
   if #b==1 and b[1].type=="IfStatement" and enumcond(b[1].clauses[1].condition) then return leaf(b[1],n) end
   return b
  end
 end
end

local function op(out,x)
 local t=x.type
 if t=="Identifier" then
  local q={inst=0,stk=1,upv=2,env=3,vararg=4,unpack=5,setmetatable=7,pc=29,top=30,wrap_proto=8}
  if q[x.name] then out[#out+1]=q[x.name] end
  return
 end
 if t=="MemberExpression" then
  if isname(x.base,"table") and x.identifier.name=="insert" then out[#out+1]=6 else out[#out+1]=9 end
 elseif t=="IndexExpression" then out[#out+1]=9
 elseif t=="IfStatement" then
  out[#out+1]=10
  for i=2,#x.clauses do out[#out+1]=x.clauses[i].type=="ElseClause" and 12 or 11 end
 elseif t=="NumericForStatement" then out[#out+1]=13
 elseif t=="CallExpression" then out[#out+1]=14
 elseif t=="ReturnStatement" then out[#out+1]=27
 elseif t=="TableConstructorExpression" then out[#out+1]=33
 elseif t=="UnaryExpression" then
  local q={["#"]=28,["-"]=31,["not"]=34}
  if q[x.operator] then out[#out+1]=q[x.operator] end
 elseif t=="BinaryExpression" or t=="LogicalExpression" then
  local q={["+"]=15,["-"]=16,["*"]=17,["/"]=18,["%"]=19,["^"]=20,["<"]=21,[">"]=22,["<="]=23,[">="]=24,["=="]=25,["~="]=26,[".."]=32,["and"]=35,["or"]=36}
  if q[x.operator] then out[#out+1]=q[x.operator] end
 end
 local fs=fields[t]
 if fs then
  for _,k in ipairs(fs) do
   local v=x[k]
   if type(v)=="table" then
    if v.type then op(out,v) else for _,z in ipairs(v) do op(out,z) end end
   end
  end
 end
end

local function fp(a)
 local out={}
 for _,x in ipairs(a) do op(out,x) end
 return table.concat(out)
end

local function shape(a)
 local out={}
 local keep={inst=true,stk=true,upv=true,env=true,vararg=true,unpack=true,setmetatable=true,pc=true,top=true,wrap_proto=true,OP_ENUM=true,OP_A=true,OP_B=true,OP_C=true}
 local function one(x)
  if type(x)~="table" then return end
  local t=x.type
  out[#out+1]="<"..t
  if t=="Identifier" then out[#out+1]=keep[x.name] and x.name or "_"
  elseif t=="NumberLiteral" then local n=x.value out[#out+1]=(n>=-1 and n<=4 and n==math.floor(n)) and tostring(n) or "n"
  elseif t=="BooleanLiteral" then out[#out+1]=x.value and "t" or "f"
  elseif t=="StringLiteral" then out[#out+1]="s"
  elseif x.operator then out[#out+1]=x.operator end
  local fs=fields[t]
  if fs then
   for _,k in ipairs(fs) do
    local v=x[k]
    if type(v)=="table" then
     if v.type then one(v) else out[#out+1]="[" for _,z in ipairs(v) do one(z) end out[#out+1]="]" end
    end
   end
  end
  out[#out+1]=">"
 end
 for _,x in ipairs(a) do one(x) end
 return table.concat(out)
end

local function pcinc(x)
 if x.type~="AssignmentStatement" or #x.variables~=1 or #x.init~=1 or not isname(x.variables[1],"pc") then return false end
 local q=x.init[1]
 return q.type=="BinaryExpression" and q.operator=="+" and ((isname(q.left,"pc") and q.right.type=="NumberLiteral") or (isname(q.right,"pc") and q.left.type=="NumberLiteral"))
end

local function instset(x)
 if x.type~="AssignmentStatement" or #x.variables~=1 or #x.init~=1 or not isname(x.variables[1],"inst") then return false end
 local q=x.init[1]
 return q.type=="IndexExpression" and isname(q.base,"insts")
end

local function split(a)
 local out={}
 local cur={}
 local prev
 for _,x in ipairs(a) do
  if prev and pcinc(prev) and instset(x) then
   if #cur>1 then table.remove(cur) else cur={} end
   out[#out+1]=cur
   cur={}
  else
   cur[#cur+1]=x
  end
  prev=x
 end
 if #cur>0 then out[#out+1]=cur end
 return out
end

local function number(x)
 if not x then return end
 if x.type=="NumberLiteral" then return x.value end
 if x.type=="UnaryExpression" and x.operator=="-" and x.argument.type=="NumberLiteral" then return -x.argument.value end
 if x.type=="ParenthesizedExpression" then return number(x.expression) end
end

local function statecmp(x,name,n)
 if not x or x.type~="BinaryExpression" then return end
 local a=number(x.left)
 local b=number(x.right)
 if isname(x.left,name) then a=n elseif isname(x.right,name) then b=n else return end
 if a==nil or b==nil then return end
 local q=x.operator
 if q=="==" then return a==b elseif q=="~=" then return a~=b elseif q=="<" then return a<b elseif q==">" then return a>b elseif q=="<=" then return a<=b elseif q==">=" then return a>=b end
end

local function resolve(a,name,n)
 local out={}
 for _,x in ipairs(a) do
  if x.type=="IfStatement" then
   local hit=false
   for _,q in ipairs(x.clauses) do
    local v=q.type=="ElseClause" and true or statecmp(q.condition,name,n)
    if v~=nil then
     if v then
      local z=resolve(q.body,name,n)
      for _,w in ipairs(z) do out[#out+1]=w end
      hit=true
      break
     end
    else
     out[#out+1]=x
     hit=true
     break
    end
   end
   if not hit then
   end
  else out[#out+1]=x end
 end
 return out
end

local function linear(a)
 local exact={}
 local marked=false
 for _,x in ipairs(a) do
  local s=x._state
  if s and s.first and s.last then
   marked=true
   for n=s.first,s.last,s.step do
    local z=resolve({x},s.name,n)
    for _,q in ipairs(z) do exact[#exact+1]=q end
   end
  else exact[#exact+1]=x end
 end
 if marked then return exact end
 local count={}
 local lo={}
 local hi={}
 local function walk(x)
  if type(x)~="table" then return end
  if x.type=="BinaryExpression" then
   local name
   local v
   if x.left.type=="Identifier" and x.left.name:sub(1,1)=="_" then name=x.left.name v=number(x.right)
   elseif x.right.type=="Identifier" and x.right.name:sub(1,1)=="_" then name=x.right.name v=number(x.left) end
   if name and v then count[name]=(count[name] or 0)+1 lo[name]=math.min(lo[name] or v,v) hi[name]=math.max(hi[name] or v,v) end
  end
  local fs=x.type and fields[x.type]
  if fs then for _,k in ipairs(fs) do local v=x[k] if type(v)=="table" then if v.type then walk(v) else for _,z in ipairs(v) do walk(z) end end end end end
 end
 for _,x in ipairs(a) do walk(x) end
 local name
 for n,c in pairs(count) do if c>=2 and (not name or c>count[name]) then name=n end end
 if not name or hi[name]-lo[name]>64 then return a end
 local out={}
 for n=lo[name],hi[name] do
  local z=resolve(a,name,n)
  for _,x in ipairs(z) do out[#out+1]=x end
 end
 return out
end

local function clone(x)
 if type(x)~="table" then return x end
 local t={}
 for k,v in pairs(x) do t[k]=clone(v) end
 return t
end

local function info(a)
 local t={}
 local function read(x)
  if type(x)~="table" then return end
  if x.type=="Identifier" and x.name:sub(1,1)=="_" then
   local q=t[x.name] or {read=0,set=0}
   q.read=q.read+1
   t[x.name]=q
   return
  end
  local fs=x.type and fields[x.type]
  if fs then for _,k in ipairs(fs) do local v=x[k] if type(v)=="table" then if v.type then read(v) else for _,z in ipairs(v) do read(z) end end end end end
 end
 local function stat(x)
  if x.type=="VariableDeclaration" then
   for _,v in ipairs(x.init or {}) do read(v) end
   for i,v in ipairs(x.variables) do
    local n=v.identifier.name
    if n:sub(1,1)=="_" then local q=t[n] or {read=0,set=0} q.value=x.init and x.init[i] t[n]=q end
   end
  elseif x.type=="AssignmentStatement" then
   for _,v in ipairs(x.init) do read(v) end
   for _,v in ipairs(x.variables) do
    if v.type=="Identifier" and v.name:sub(1,1)=="_" then local q=t[v.name] or {read=0,set=0} q.set=q.set+1 t[v.name]=q
    else read(v) end
   end
  else read(x) end
 end
 for _,x in ipairs(a) do stat(x) end
 return t
end

local function simple(a)
 local function symbols()
  local t={}
  local function read(x)
   if type(x)~="table" then return end
   if x.type=="Identifier" then
    local q=t[x.name]
    if q then q.read=q.read+1 end
    return
   end
   local fs=x.type and fields[x.type]
   if fs then for _,k in ipairs(fs) do local v=x[k] if type(v)=="table" then if v.type then read(v) else for _,z in ipairs(v) do read(z) end end end end end
  end
  local function stat(x)
   if x.type=="VariableDeclaration" then
    for _,v in ipairs(x.init or {}) do read(v) end
    for i,v in ipairs(x.variables) do t[v.identifier.name]={value=(x.init or {})[i] or (x.init or {})[#(x.init or {})],decl=x,read=0,set=0} end
   elseif x.type=="AssignmentStatement" then
    for _,v in ipairs(x.init) do read(v) end
    for i,v in ipairs(x.variables) do
     if v.type=="Identifier" then
      local q=t[v.name]
      if q then q.value=nil q.set=q.set+1 else t[v.name]={value=x.init[i] or x.init[#x.init],decl=x,read=0,set=0} end
     else read(v) end
    end
   else read(x) end
  end
  for _,x in ipairs(a) do stat(x) end
  return t
 end
 for _=1,32 do
  local inf=symbols()
  local changed=false
  local function alias(x)
   if x and x.type=="Identifier" and x.name:sub(1,1)=="_" then local q=inf[x.name] if q and q.value and q.value.type=="Identifier" then changed=true return clone(q.value) end end
   return x
  end
  local function elem(x)
   if x and x.type=="Identifier" and x.name:sub(1,1)=="_" then
    local q=inf[x.name]
    local v=q and q.value
    if v and v.type=="IndexExpression" and v.base.type=="Identifier" and v.index.type=="Identifier" and q.read==1 then changed=true return clone(v) end
   end
   return x
  end
  local function binary(x)
   if x and x.type=="Identifier" and x.name:sub(1,1)=="_" then
    local q=inf[x.name]
    if q and q.value and (q.value.type=="BinaryExpression" or q.value.type=="LogicalExpression") and q.read==1 and q.set==0 then changed=true return clone(q.value) end
   end
   return x
  end
  local function rep(x)
   if type(x)~="table" then return x end
   local fs=x.type and fields[x.type]
   if fs then for _,k in ipairs(fs) do local v=x[k] if type(v)=="table" then if v.type then x[k]=rep(v) else for i,z in ipairs(v) do v[i]=rep(z) end end end end end
   if x.type=="CallExpression" and isname(x.base,"stk") and #x.arguments==2 then x.arguments[1]=elem(x.arguments[1]) x.arguments[2]=elem(x.arguments[2])
   elseif x.type=="IndexExpression" then
    local b,i=alias(x.base),alias(x.index)
    if b~=x.base or i~=x.index then x.base=b x.index=i else x.index=elem(x.index) end
   elseif x.type=="BinaryExpression" or x.type=="LogicalExpression" then
    local l,r=elem(x.left),elem(x.right)
    if l~=x.left or r~=x.right then x.left=l x.right=r else x.left=alias(x.left) x.right=alias(x.right) end
   elseif x.type=="AssignmentStatement" then
    if #x.variables==1 and #x.init==1 and x.variables[1].type=="IndexExpression" and x.init[1].type=="Identifier" then x.init[1]=elem(x.init[1])
    elseif #x.variables==1 and #x.init==1 and x.variables[1].type=="Identifier" and x.init[1].type=="Identifier" then x.init[1]=binary(x.init[1]) end
   end
   return x
  end
  for i,x in ipairs(a) do a[i]=rep(x) end
  inf=symbols()
  for i=#a,1,-1 do
   local x=a[i]
   if x.type=="VariableDeclaration" then
    local used=false
    for _,v in ipairs(x.variables) do local q=inf[v.identifier.name] if q and q.read>0 then used=true break end end
    if not used then table.remove(a,i) changed=true end
   elseif x.type=="AssignmentStatement" then
    local localize=#x.variables>0
    for _,v in ipairs(x.variables) do local q=v.type=="Identifier" and inf[v.name] if not q or v.name:sub(1,1)~="_" or q.decl~=x then localize=false break end end
    if localize then
     local vs={}
     for _,v in ipairs(x.variables) do vs[#vs+1]={type="Variable",identifier=v} end
     a[i]={type="VariableDeclaration",variables=vs,init=x.init}
     changed=true
    end
   end
  end
  if not changed then break end
 end
 return a
end

local function choose(root,n,s)
 local cs={}
 for v in s:gmatch("[^;]+") do cs[#cs+1]=v end
 if #cs==1 then return cs[1] end
 local function rate(v)
  local fs={}
  for q in v:gmatch("%d+") do fs[#fs+1]=q end
  local score=0
  local function walkf(f)
   local ins=f.instructions or {}
   for i,x in ipairs(ins) do
    if x.op==n then
     for j,p in ipairs(fs) do
      local y=ins[math.min(i+j-1,#ins)]
      local q=ops[p]
      if not y or not q then score=score-10000 else
       local z={a=y.a,b=y.b,c=y.c,pc=y.pc}
       local ok=not q[2] or pcall(q[2],z)
       if not ok then score=score-10000 else
        local op=q[1]
        if z.a>=0 and z.a<512 then score=score+2 else score=score-20 end
        local function con(k)
         if k>=0 and k<#(f.constants or {}) then score=score+80 else score=score-400 end
        end
        local function rk(k)
         if k>=256 then con(k-256) elseif k>=0 and k<512 then score=score+2 else score=score-20 end
        end
        if op=="LoadK" or op=="GetGlobal" or op=="SetGlobal" then con(z.b)
        elseif op=="Closure" then if z.b>=0 and z.b<#(f.functions or {}) then score=score+120 else score=score-600 end
        elseif op=="GetTable" or op=="Self" then rk(z.c)
        elseif op=="SetTable" or op=="Eq" or op=="Lt" or op=="Le" or op=="Add" or op=="Sub" or op=="Mul" or op=="Div" or op=="Mod" or op=="Pow" then rk(z.b) rk(z.c)
        elseif op=="Jmp" or op=="ForLoop" or op=="ForPrep" then local t=i+z.b+1 if t>=1 and t<=#ins then score=score+30 else score=score-100 end
        elseif op=="LoadBool" then if (z.b==0 or z.b==1) and (z.c==0 or z.c==1) then score=score+20 else score=score-50 end
        elseif op=="Call" or op=="Return" or op=="VarArg" or op=="SetList" then if z.b>=0 and z.b<512 and z.c>=0 and z.c<512 then score=score+8 else score=score-30 end end
        if op=="Return" or op=="TailCall" then score=score-1000 end
       end
      end
     end
    end
   end
   for _,f2 in ipairs(f.functions or {}) do walkf(f2) end
  end
  walkf(root)
  return score
 end
 local best=cs[1]
 local bs=rate(best)
 for i=2,#cs do local q=rate(cs[i]) if q>bs then best=cs[i] bs=q end end
 return best
end

function m.raw(a,plain)
 flow.run(a.funcs[12])
 local tree=find(a.funcs[12])
 if not tree then return nil,"MoonSec dispatch tree was not found" end
 local need={}
 local function add(f) for _,x in ipairs(f.instructions or {}) do need[x.op]=true end for _,x in ipairs(f.functions or {}) do add(x) end end
 add(a.root)
 local map={}
 local keys={}
 for n in pairs(need) do
  local body=leaf(tree,n)
  if not body then return nil,"MoonSec handler "..n.." was not found" end
  map[n]={}
  local sk={}
  for _,x in ipairs(split(linear(body))) do x=simple(x) map[n][#map[n]+1]=fp(x) sk[#sk+1]=shape(x) end
  keys[n]=table.concat(map[n],",").."|"..table.concat(sk,",")
  local q=not plain and wraps[keys[n]]
  if q then q=choose(a.root,n,q) end
  if q then
   map[n]={}
   for v in q:gmatch("%d+") do map[n][#map[n]+1]=v end
  end
 end
 return map,keys
end

function m.known(map)
 local n=0
 local total=0
 for _,a in pairs(map) do for _,x in ipairs(a) do total=total+1 if ops[x] then n=n+1 end end end
 return n,total
end

m.fp=fp
function m.body(a,n)
 flow.run(a.funcs[12])
 local tree=find(a.funcs[12])
 return tree and leaf(tree,n)
end
return m
