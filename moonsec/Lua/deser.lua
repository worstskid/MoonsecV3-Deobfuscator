local read=require("moonsec.Lua.read")
local str=require("moonsec.Lua.str")
local m={}

local function bits(n,a,b)
 return math.floor(n/2^(a-1))%2^(b-a+1)
end

local function inst(r,f)
 local n=r:i32()
 local t={}
 for pc=0,n-1 do
  local d=r:u8()
  if bits(d,1,1)==0 then
   local ty=bits(d,2,3)
   local x={op=r:i16(),a=r:i16(),b=0,c=0,pc=pc,fn=f}
   if ty==0 then x.b=r:i16() x.c=r:i16()
   elseif ty==1 then x.b=r:i32()
   elseif ty==2 then x.b=r:i32()-65536
   else x.b=r:i32()-65536 x.c=r:i16() end
   local mask=bits(d,4,6)
   x.ka=bits(mask,1,1)==1
   x.kb=bits(mask,2,2)==1
   x.kc=bits(mask,3,3)==1
   t[#t+1]=x
  end
 end
 return t
end

local function funcs(r,c)
 local t={}
 for i=1,r:i32() do t[i]=m.func(r,c) end
 return t
end

local function consts(r,c)
 local t={}
 for i=1,r:i32() do
  local ty=c.types[r:u8()]
  if ty=="bool" then t[i]={type=ty,value=r:bool()}
  elseif ty=="number" then t[i]={type=ty,value=r:f64()}
  elseif ty=="string" then t[i]={type=ty,value=str.one(r:take(r:i32()),c.ckey)}
  else t[i]={type="nil"} end
 end
 return t
end

function m.func(r,c)
 local f={}
 for _,s in ipairs(c.order) do
  if s=="instructions" then f.instructions=inst(r,f)
  elseif s=="constants" then f.constants=consts(r,c)
  elseif s=="functions" then f.functions=funcs(r,c)
  elseif s=="params" then f.params=r:u8() end
 end
 return f
end

function m.run(s,c)
 return m.func(read.new(s),c)
end

return m
