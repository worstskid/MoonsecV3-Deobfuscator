package.path="prometheus/?.lua;prometheus/?/init.lua;"..package.path

local b=require("src.beautify")
local i=assert(io.open(arg[1],"rb"))
local s=i:read("*a")
i:close()
local o=assert(io.open(arg[1],"wb"))
o:write(b.run(s))
o:close()
