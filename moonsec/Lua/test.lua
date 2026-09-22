package.path="./?.lua;./?/init.lua;"..package.path
local str=require("moonsec.Lua.str")
local read=require("moonsec.Lua.read")
local scan=require("moonsec.Lua.scan")
local byte=require("moonsec.Lua.byte")
local emit=require("moonsec.Lua.emit")

local function eq(a,b,n)
 if a~=b then error(n..": "..tostring(a).." ~= "..tostring(b)) end
end

eq(str.esc("\\65\\66\\67"),"ABC","escape")
eq(str.one(string.char(200,250,251),10),string.char(4,5),"constant")
local r=read.new(string.char(0,0,0,0,0,0,240,63))
eq(r:f64(),1,"double")
local p=string.char(0,2).."hi"..string.char(1).."x".."12345678"..string.char(5)
eq(str.pool(p)["12345678"][2],"x","pool")
eq(#scan.strings('local x="\\65\\66"'),1,"scan")
local f=io.open("moonsec/tests/public/case01.lua","rb")
if f then
 local s=f:read("*a")
 f:close()
 if #scan.constants(s)<1 then error("public pool") end
end
local op={instructions={{op=7,a=0,b=1,c=0}},constants={},functions={}}
byte.identify(op,{[7]="1419090"})
eq(op.instructions[1].code,"LoadK","opcode")
eq(op.instructions[1].b,0,"operand")
local root={
 params=0,
 constants={{type="string",value="print"},{type="string",value="lua emitter"}},
 functions={},
 instructions={
  {code="GetGlobal",a=0,b=0,c=0},
  {code="LoadK",a=1,b=1,c=0},
  {code="Call",a=0,b=2,c=1},
  {code="Return",a=0,b=1,c=0}
 }
}
local fn=assert(loadstring(emit.run(root)))
local got
setfenv(fn,setmetatable({print=function(v)got=v end},{__index=_G}))
fn()
eq(got,"lua emitter","emitter")
print("moonsec lua core: 9/9")
