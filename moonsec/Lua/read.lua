local m={}

local function new(s)
 local r={s=s,p=1}
 function r:u8()
  local v=self.s:byte(self.p)
  if not v then error("bytecode ended early") end
  self.p=self.p+1
  return v
 end
 function r:u16()
  local a,b=self:u8(),self:u8()
  return a+b*256
 end
 function r:i16()
  local v=self:u16()
  return v>=32768 and v-65536 or v
 end
 function r:u32()
  local a,b,c,d=self:u8(),self:u8(),self:u8(),self:u8()
  return a+b*256+c*65536+d*16777216
 end
 function r:i32()
  local v=self:u32()
  return v>=2147483648 and v-4294967296 or v
 end
 function r:take(n)
  local v=self.s:sub(self.p,self.p+n-1)
  if #v~=n then error("bytecode ended early") end
  self.p=self.p+n
  return v
 end
 function r:bool() return self:u8()~=0 end
 function r:f64()
  local lo=self:u32()
  local hi=self:u32()
  local sign=hi>=2147483648 and -1 or 1
  if hi>=2147483648 then hi=hi-2147483648 end
  local exp=math.floor(hi/1048576)
  local frac=(hi%1048576)*4294967296+lo
  if exp==2047 then return frac==0 and sign*math.huge or 0/0 end
  if exp==0 then return sign*2^-1022*(frac/4503599627370496) end
  return sign*2^(exp-1023)*(1+frac/4503599627370496)
 end
 return r
end

m.new=new
return m
