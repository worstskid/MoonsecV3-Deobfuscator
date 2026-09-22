package.path="./?.lua;./?/init.lua;"..package.path
local deob=require("moonsec.Lua.deob")
local cases={1,2,3,5,6,7,8,9,10,11,12,13,14,16,19,20,21,22,25,26,28,29,30,31,32,33,34,36,37,39}
local streak=0
for _,i in ipairs(cases) do
 local n=string.format("case%02d",i)
 local f=assert(io.open("moonsec/tests/public/"..n..".lua","rb"))
 local src=f:read("*a")
 f:close()
 local out,meta=deob.run(src)
 assert(out,meta)
 assert(loadstring(out))
 local count=0
 for _ in out:gmatch("p==%d+") do count=count+1 end
 assert(count>0,"empty recovery")
 streak=streak+1
 print("PASS",streak,n,count)
end
print("STREAK",streak)
