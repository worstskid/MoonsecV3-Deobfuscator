local str=require("moonsec.Lua.str")
local m={}

function m.strings(s)
 local t={}
 for q,v in s:gmatch("(['\"])(.-)%1") do
  if v:match("^\\%d+\\%d+") then t[#t+1]=str.esc(v) end
 end
 return t
end

function m.constants(s)
 local out={}
 for _,v in ipairs(m.strings(s)) do
  local ok,r=pcall(str.pool,v)
  if ok and next(r) then out[#out+1]=r end
 end
 return out
end

return m
