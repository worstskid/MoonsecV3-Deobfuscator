local ops=require("moonsec.Lua.ops")
local m={}

local function walk(f,fn)
 fn(f)
 for _,x in ipairs(f.functions or {}) do walk(x,fn) end
end

function m.identify(root,map)
 walk(root,function(f)
 local i=1
  local jumps={}
  while i<=#(f.instructions or {}) do
   local x=f.instructions[i]
   local hs=map[x.op]
   if not hs then error("handler missing for opcode "..tostring(x.op)) end
   if type(hs)=="string" then hs={hs} end
   for n,fp in ipairs(hs) do
    local q=ops[fp]
    if not q then error("unknown handler fingerprint: "..fp) end
    if n>1 and i<#f.instructions then
     i=i+1
     x=f.instructions[i]
    end
    x.code=q[1]
    if q[2] then q[2](x) end
    if x.code=="Jmp" then jumps[i+(x.b or 0)+1]=true end
    if x.code=="Return" or x.code=="TailCall" then
     local stop=i+1
     while stop<=#f.instructions and not jumps[stop] do stop=stop+1 end
     local count=stop-i-1
     if count<=100 or count<=math.floor((#f.instructions-i)*0.25) then
      while i+1<stop do i=i+1 f.instructions[i].dead=true end
     end
     break
    end
   end
   i=i+1
  end
 end)
 return root
end

local function refs(a)
 local t={}
 for i,x in ipairs(a) do
  if x.code=="Jmp" or x.code=="ForLoop" or x.code=="ForPrep" then
   local q=i+(x.b or 0)+1
   while q<=#a and a[q] and a[q].dead do q=q+1 end
   if q>#a then
    q=#a
    while q>0 and a[q].dead do q=q-1 end
   end
   if q>0 and a[q] then t[x]=a[q] end
  end
 end
 return t
end

local function flow(f)
 local a=f.instructions or {}
 local r=refs(a)
 for i=#a,1,-1 do if a[i].dead then table.remove(a,i) end end
 local i=1
 while i<=#a-2 do
  local x=a[i]
  if (x.code=="Eq" or x.code=="Lt" or x.code=="Le" or x.code=="Test") and a[i+1].code=="Jmp" and a[i+2].code=="Jmp" then
   if x.code=="Test" then x.c=x.c==1 and 0 or 1 else x.a=x.a==1 and 0 or 1 end
   table.remove(a,i+1)
  end
  i=i+1
 end
 i=1
 while i<=#a do
  local x=a[i]
  if x.code=="TailCall" and (not a[i+1] or a[i+1].code~="Return") then
   table.insert(a,i+1,{code="Return",a=x.a,b=1,c=0})
  end
  i=i+1
 end
 local pos={}
 for n,x in ipairs(a) do pos[x]=n end
 for n,x in ipairs(a) do
  if r[x] and pos[r[x]] then x.b=pos[r[x]]-(n+1) end
  x.pc=n-1
 end
 for _,x in ipairs(f.functions or {}) do flow(x) end
end

local function pool(f)
 local map={}
 local out={}
 local function one(n)
  if map[n]==nil then
   map[n]=#out
   out[#out+1]=f.constants[n+1]
  end
  return map[n]
 end
 local function rk(n) return n>=256 and one(n-256)+256 or n end
 for _,x in ipairs(f.instructions or {}) do
  local c=x.code
  if c=="LoadK" or c=="GetGlobal" or c=="SetGlobal" then
   x.b=one(x.b)
  elseif c=="SetTable" or c=="Eq" or c=="Lt" or c=="Le" or c=="Add" or c=="Sub" or c=="Mul" or c=="Div" or c=="Mod" or c=="Pow" then
   x.b=rk(x.b)
   x.c=rk(x.c)
  elseif c=="GetTable" or c=="Self" then
   x.c=rk(x.c)
  end
 end
 f.constants=out
 for _,x in ipairs(f.functions or {}) do pool(x) end
end

local function flags(f)
 local top=0
 f.vararg=0
 for i,x in ipairs(f.instructions or {}) do
  if (x.a or 0)>top then top=x.a end
  if x.code=="Closure" and f.functions[x.b+1] then f.functions[x.b+1].upvalues=x.c or 0 end
  if x.code=="VarArg" then f.vararg=2 end
  x.pc=i-1
 end
 f.stack=top+1
 for _,x in ipairs(f.functions or {}) do flags(x) end
end

local function entry(f)
 local at
 for i,x in ipairs(f.instructions or {}) do
  if x.code=="Eq" and (x.c or 0)>255 then
   local k=f.constants[x.c-255]
   if k and k.type=="string" and k.value:find("^This file was protected with MoonSec V3") then at=i break end
  end
 end
 if not at then return end
 for i=at,#f.instructions do
  if f.instructions[i].code=="Return" then
   if i<#f.instructions then for _=1,i do table.remove(f.instructions,1) end end
   break
  end
 end
 local used={}
 for _,x in ipairs(f.instructions) do if x.code=="Closure" and f.functions[x.b+1] then used[f.functions[x.b+1]]=true end end
 local out={}
 for _,x in ipairs(f.functions or {}) do if used[x] then out[#out+1]=x end end
 for _,x in ipairs(f.instructions) do
  if x.code=="Closure" and f.functions[x.b+1] then
   local q=f.functions[x.b+1]
   for i,v in ipairs(out) do if v==q then x.b=i-1 break end end
  end
 end
 f.functions=out
end

function m.clean(root)
 flow(root)
 entry(root)
 pool(root)
 flags(root)
 root.vararg=2
 return root
end

return m
