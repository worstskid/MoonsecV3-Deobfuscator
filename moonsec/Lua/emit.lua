local m={}

local function quote(s)
 return '"'..s:gsub('[%z\1-\31\\"]',function(c)
  if c=="\\" or c=='"' then return "\\"..c end
  if c=="\n" then return "\\n" end
  if c=="\r" then return "\\r" end
  if c=="\t" then return "\\t" end
  return "\\"..string.format("%03d",c:byte())
 end)..'"'
end

local function kval(x)
 if not x or x.type=="nil" then return "nil" end
 if x.type=="string" then return quote(x.value) end
 if x.type=="bool" then return x.value and "true" or "false" end
 return tostring(x.value)
end

local function reg(f,n)
 return n>255 and n-255<=#f.constants and kval(f.constants[n-255]) or "r["..n.."]"
end

local function glob(f,n)
 return n>=0 and f.constants[n+1] and kval(f.constants[n+1]) or "nil"
end

local function args(a,b)
 if b==1 then return "" end
 if b==0 then return "q(r,"..(a+1)..",top)" end
 if b<1 then return "" end
 if b>64 then return "q(r,"..(a+1)..","..(a+b-1)..")" end
 local t={}
 for i=a+1,a+b-1 do t[#t+1]="r["..i.."]" end
 return table.concat(t,",")
end

local function list(a,n)
 local t={}
 if n<=0 then return "" end
 for i=a,a+n-1 do t[#t+1]="r["..i.."]" end
 return table.concat(t,",")
end

local function add(b,s) b[#b+1]=s end

local function call(b,a,d,c)
 local q="r["..a.."]("..args(a,d)..")"
 if c==0 then
  add(b,"local x=z("..q..")")
  add(b,"for i=1,x.n do r["..a.."+i-1]=x[i] end")
  add(b,"top="..a.."+x.n-1")
 elseif c<=1 then
  add(b,q)
 elseif c>64 then
  add(b,"local x=z("..q..")")
  add(b,"for i=1,"..(c-1).." do r["..a.."+i-1]=x[i] end")
 else
  add(b,list(a,c-1).."="..q)
 end
end

local function ins(b,f,x,i,ids)
 add(b,(i==0 and "if" or "elseif").." p=="..(i+1).." then")
 local a=x.a or 0
 local c=x.c or 0
 local d=x.b or 0
 local n=i+2
 local op=x.code
 local bin={Add="+",Sub="-",Mul="*",Div="/",Mod="%",Pow="^"}
 if op=="Move" then
  add(b,"r["..a.."]=r["..d.."]")
 elseif op=="LoadK" then
  add(b,"r["..a.."]="..glob(f,d))
 elseif op=="LoadBool" then
  add(b,"r["..a.."]="..(d~=0 and "true" or "false"))
  if c~=0 then n=n+1 end
 elseif op=="LoadNil" then
  add(b,"for i="..a..","..d.." do r[i]=nil end")
 elseif op=="GetUpval" then
  add(b,"r["..a.."]=u["..(d+1).."]")
 elseif op=="GetGlobal" then
  add(b,"r["..a.."]=e["..glob(f,d).."]")
 elseif op=="GetTable" then
  add(b,"r["..a.."]=r["..d.."]["..reg(f,c).."]")
 elseif op=="SetGlobal" then
  add(b,"e["..glob(f,d).."]=r["..a.."]")
 elseif op=="SetUpval" then
  add(b,"u["..(d+1).."]=r["..a.."]")
 elseif op=="SetTable" then
  add(b,"r["..a.."]["..reg(f,d).."]="..reg(f,c))
 elseif op=="NewTable" then
  add(b,"r["..a.."]={}")
 elseif op=="Self" then
  add(b,"r["..(a+1).."]=r["..d.."];r["..a.."]=r["..d.."]["..reg(f,c).."]")
 elseif bin[op] then
  add(b,"r["..a.."]="..reg(f,d)..bin[op]..reg(f,c))
 elseif op=="Unm" then
  add(b,"r["..a.."]=-r["..d.."]")
 elseif op=="Not" then
  add(b,"r["..a.."]=not r["..d.."]")
 elseif op=="Len" then
  add(b,"r["..a.."]=#r["..d.."]")
 elseif op=="Concat" then
 local t={}
  for j=d,c do t[#t+1]="r["..j.."]" end
  add(b,"r["..a.."]="..(#t>0 and table.concat(t,"..") or "nil"))
 elseif op=="Jmp" then
  n=i+2+d
 elseif op=="Eq" or op=="Lt" or op=="Le" then
  local q=op=="Eq" and "==" or op=="Lt" and "<" or "<="
  add(b,"if (("..reg(f,d)..q..reg(f,c)..")~="..(a~=0 and "true" or "false")..") then p="..(i+3).." else p="..(i+2).." end")
  return
 elseif op=="Test" then
  add(b,"if "..(c==0 and "not " or "").."r["..a.."] then p="..(i+2).." else p="..(i+3).." end")
  return
 elseif op=="TestSet" then
  add(b,"if "..(c==0 and "not " or "").."r["..d.."] then r["..a.."]=r["..d.."];p="..(i+2).." else p="..(i+3).." end")
  return
 elseif op=="Call" then
  call(b,a,d,c)
 elseif op=="TailCall" then
  add(b,"return r["..a.."]("..args(a,d)..")")
  return
 elseif op=="Return" then
  if d==0 then add(b,"return q(r,"..a..",top)")
  elseif d==1 then add(b,"return")
  elseif d>65 then add(b,"return q(r,"..a..","..(a+d-2)..")")
  elseif d>1 then add(b,"return "..list(a,d-1)) else add(b,"return") end
  return
 elseif op=="ForPrep" then
  add(b,"r["..a.."]=r["..a.."]-r["..(a+2).."]")
  n=i+2+d
 elseif op=="ForLoop" then
  add(b,"r["..a.."]=r["..a.."]+r["..(a+2).."]")
  add(b,"if (r["..(a+2).."]>0 and r["..a.."]<=r["..(a+1).."]) or (r["..(a+2).."]<=0 and r["..a.."]>=r["..(a+1).."]) then r["..(a+3).."]=r["..a.."];p="..(i+2+d).." else p="..(i+2).." end")
  return
 elseif op=="TForLoop" then
  add(b,"local x=z(r["..a.."](r["..(a+1).."],r["..(a+2).."]))")
  add(b,"for i=1,"..c.." do r["..(a+2).."+i]=x[i] end")
  add(b,"if r["..(a+3).."]~=nil then r["..(a+2).."]=r["..(a+3).."];p="..(i+2).." else p="..(i+3).." end")
  return
 elseif op=="SetList" then
  add(b,"local m="..((c-1)*50))
  add(b,"for i=1,"..(d==0 and "top-"..a or d).." do r["..a.."][m+i]=r["..a.."+i] end")
 elseif op=="Close" then
 elseif op=="Closure" then
  local fn=f.functions[d+1]
  if not fn then
   add(b,"r["..a.."] = function()end")
   add(b,"p="..n)
   return
  end
  local u={}
  for j=1,math.min(fn and fn.upvalues or 0,#f.instructions-i-1) do
   local y=f.instructions[i+j]
   u[#u+1]=y.code=="Move" and "r["..y.b.."]" or "u["..(y.b+1).."]"
  end
  if #u<=64 then add(b,"local v={"..table.concat(u,",").."}") else
   add(b,"local v={}")
   for j,q in ipairs(u) do add(b,"v["..j.."]="..q) end
  end
  add(b,"r["..a.."] = function(...)return f["..ids[fn].."](v,...)end")
  n=n+(fn and fn.upvalues or 0)
 elseif op=="VarArg" then
  if d==0 then
   add(b,"for i=1,a.n do r["..a.."+i-1]=a[i] end")
   add(b,"top="..a.."+a.n-1")
  elseif d>1 then
   add(b,"for i=1,"..(d-1).." do r["..a.."+i-1]=a[i] end")
  end
 else
  error("unknown opcode "..tostring(op))
 end
 add(b,"p="..n)
end

function m.run(root)
 local ids={}
 local order={}
 local function walk(f)
  if ids[f]~=nil then return end
  ids[f]=#order
  order[#order+1]=f
  for _,x in ipairs(f.functions or {}) do walk(x) end
 end
 walk(root)
 local b={
  "--[=[ deobfuscated by sergei.dev @ .gg/svgmV95Apm ]=]--",
  "local e=getfenv and getfenv() or _ENV",
  "local q=table.unpack or unpack",
  "local function z(...)return {n=select('#',...),...}end",
  "local f={}"
 }
 for n=#order,1,-1 do
  local f=order[n]
  add(b,"f["..ids[f].."] = function(u,...)")
  add(b,"local r={}")
  add(b,"local a=z(...)")
  add(b,"for i=1,"..(f.params or 0).." do r[i-1]=a[i] end")
  add(b,"local top="..math.max(0,(f.params or 0)-1))
  if #(f.instructions or {})==0 then add(b,"return") else
   add(b,"local p=1")
   add(b,"while true do")
   for i,x in ipairs(f.instructions or {}) do ins(b,f,x,i-1,ids) end
   add(b,"else break end")
   add(b,"end")
  end
  add(b,"end")
 end
 add(b,"return f[0]({},...)")
 return table.concat(b,"\n").."\n"
end

return m
