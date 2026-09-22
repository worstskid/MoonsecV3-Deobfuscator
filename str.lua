local m={}

function m.esc(s)
 local t={}
 for n in s:gmatch("\\(%d+)") do t[#t+1]=string.char(tonumber(n)%256) end
 return table.concat(t)
end

function m.dec(s,k)
 if #s<16 then return nil,"alphabet not found" end
 local a={}
 for i=1,16 do a[s:sub(i,i)]=i-1 end
 local t={}
 local r=k
 for i=17,#s,2 do
  local x=a[s:sub(i,i)] or 0
  local y=a[s:sub(i+1,i+1)] or 0
  t[#t+1]=string.char((x*16+y+r)%256)
  r=r+k
 end
 return table.concat(t)
end

function m.one(s,k)
 if #s>1 and s:byte(1)>127 then
  local t={}
  for i=2,#s do t[#t+1]=string.char((s:byte(i)+k)%256) end
  return table.concat(t)
 end
 return s
end

function m.pool(s)
 local i=1
 local t={}
 local function byte()
  local v=s:byte(i)
  if not v then error("constant pool ended early") end
  i=i+1
  return v
 end
 local function take(n)
  local v=s:sub(i,i+n-1)
  if #v~=n then error("constant pool ended early") end
  i=i+n
  return v
 end
 while true do
  local c=byte()
  if c==5 then break end
  if c==1 then c=2 end
  local a=take(byte())
  local v
  if c==0 then v={a,take(byte())} elseif c==2 or c==4 or c==6 then v={a} end
  t[take(8)]=v
 end
 return t
end

return m
