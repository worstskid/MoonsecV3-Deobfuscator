local analyze=require("moonsec.Lua.analyze")
local handlers=require("moonsec.Lua.handlers")
local byte=require("moonsec.Lua.byte")
local emit=require("moonsec.Lua.emit")
local m={}

function m.run(src)
 local a,err=analyze.run(src)
 if not a then return nil,err end
 local map
 map,err=handlers.raw(a)
 if not map then return nil,err end
 local known,total=handlers.known(map)
 if known~=total then
  local plain,pe=handlers.raw(a,true)
  if plain then
   local pk,pt=handlers.known(plain)
   if pk*total>known*pt then map,known,total=plain,pk,pt end
  end
 end
 if known~=total then return nil,"unknown MoonSec handlers: "..known.."/"..total end
 local ok,res=pcall(function()
  byte.identify(a.root,map)
  byte.clean(a.root)
  return emit.run(a.root)
 end)
 if not ok then return nil,res end
 return res,{key=a.ctx.bkey,bytes=a.bytes,handlers=total,instructions=#a.root.instructions,functions=#a.root.functions}
end

return m
