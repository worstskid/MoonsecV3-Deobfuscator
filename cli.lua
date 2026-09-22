local file=debug.getinfo(1,"S").source:gsub("^@","")
local dir=file:match("^(.*)[/\\]") or "."
local root=dir.."/../.."
package.path=dir.."/?.lua;"..dir.."/?/init.lua;"..root.."/?.lua;"..root.."/?/init.lua;"..package.path
local ok,deob=pcall(require,"moonsec.Lua.deob")
if not ok then deob=require("deob") end

local input=arg[1]
local output=arg[2]
if not input or not output then
 io.stderr:write("usage: lua moonsec/Lua/cli.lua input.lua output.lua\n")
 os.exit(1)
end
local f,e=io.open(input,"rb")
if not f then io.stderr:write(e.."\n") os.exit(1) end
local src=f:read("*a")
f:close()
local out,meta=deob.run(src)
local fallback=false
local function q(x) return '"'..tostring(x):gsub('"','\\"')..'"' end
if not out then
 local okfallback=meta and meta:match("unknown MoonSec handlers")
 local tool=root.."/moonsec/tool/bin/Release/net9.0/MoonsecDeobfuscator.dll"
 if okfallback and io.open(tool,"rb") then
  local cmd="dotnet "..q(tool).." -src -i "..q(input).." -o "..q(output).." >NUL 2>NUL"
  os.execute(cmd)
  local rf=io.open(output,"rb")
  if rf then out=rf:read("*a") rf:close() fallback=out and #out>0 end
 end
 if not out then io.stderr:write(meta.."\n") os.exit(1) end
end
if fallback then
 f,e=io.open(output,"wb")
 if f then f:write(out) f:close() end
 os.execute("node "..q(dir.."/fallback.js").." "..q(output).." luac >NUL 2>NUL")
 f=io.open(output,"rb")
 if f then out=f:read("*a") f:close() end
end
local function repair(s)
 local a={}
 for x in s:gmatch("[^\n]*\n?") do
 if x=="" then break end
  if x:match("^%s*var%d+%s+then%s*$") then x="" end
  local d,v=x:match("^(%s*if.-%s+)(var%d+)%s*=%s*_G%[.-%]%s*%2%s*=")
  if d then
   x=d..v.." then\n"
  elseif x:match("^%s*if\b") and not x:match("%b()") and x:match("%svar%d+%s*=%s*[%\"']") and not x:match("%svar%d+%s*=%s*.-%s+var%d+%s*=") then
   x=x:gsub("(var%d+)%s*=%s*([%\"'])","%1 == %2")
   if not x:match("then%s*$") then x=x:gsub("%s*$"," then\n") end
  end
 a[#a+1]=x
 end
 for i=2,#a-1 do
  if a[i]:match("^%s*else%s*$") and a[i-1]:match("var%d+%([^)]*%)") and a[i+1]:match("^%s*var%d+%s*=%s*_G%[\"print\"%]") then
   local d=a[i]:match("^%s*") or ""
   table.insert(a,i,d.."end\n")
   i=i+1
  end
 end
 return table.concat(a)
end
out=repair(out)
out=out:gsub("function%s+(%d+):(%d+)%s*%(","function f%1_%2(")
out=out:gsub("function%s+(%d+)%s*%(","function f%1(")
local fn,err=loadstring(out)
if not fn then
 if fallback then
  f,e=io.open(output,"wb")
  if f then f:write(out) f:close() end
  print(output)
  print("warning: fallback source needs syntax repair")
  os.exit(0)
 end
 if meta then io.stderr:write(meta.."; fallback output: "..err.."\n") else io.stderr:write(err.."\n") end
 os.exit(1)
end
f,e=io.open(output,"wb")
if not f then io.stderr:write(e.."\n") os.exit(1) end
f:write(out)
f:close()
print(output)
if type(meta)=="table" then
 print("key: "..meta.key)
 print("bytes: "..meta.bytes)
 print("handlers: "..meta.handlers)
 print("instructions: "..meta.instructions)
 print("functions: "..meta.functions)
else
 print("mode: executable fallback")
end
