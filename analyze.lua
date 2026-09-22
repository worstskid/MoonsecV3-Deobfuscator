local parser=require("moonsec.Lua.luaparse.parser")
local eval=require("moonsec.Lua.eval")
local str=require("moonsec.Lua.str")
local deser=require("moonsec.Lua.deser")
local scan=require("moonsec.Lua.scan")
local norm=require("moonsec.Lua.norm")
local m={}

local fields=parser.node_fields

local function walk(x,fn)
 if type(x)~="table" then return end
 fn(x)
 local a=x.type and fields[x.type]
 if not a then return end
 for _,k in ipairs(a) do
  local v=x[k]
  if type(v)=="table" then
   if v.type then walk(v,fn) else for _,q in ipairs(v) do walk(q,fn) end end
  end
 end
end

local function eqs(x)
 local t={}
 walk(x,function(q)
  if q.type=="BinaryExpression" and q.operator=="==" and q.right.type=="NumberLiteral" then t[#t+1]=q.right.value end
 end)
 return t
end

function m.run(src)
 local ast=parser.parse(src,{lua_version="5.1"}).ast
 local pools=scan.constants(src)
 walk(ast,function(x)
  if x.type=="CallExpression" and #x.arguments==2 and x.arguments[1].type=="NumberLiteral" and x.arguments[2].type=="StringLiteral" then
   local ok,raw=pcall(str.dec,x.arguments[2].value,math.floor(x.arguments[1].value))
   if ok and raw then
    local pass,pool=pcall(str.pool,raw)
    if pass and next(pool) then pools[#pools+1]=pool end
   end
  end
 end)
 norm.run(ast,pools)
 local funcs={}
 local keys={}
 local blobs={}
 walk(ast,function(x)
  if x.type=="FunctionDeclaration" and x.scope=="local" and x.identifier then funcs[#funcs+1]=x end
  if x.type=="BinaryExpression" and x.operator=="+" and x.right.type=="CallExpression" then keys[#keys+1]=x end
  if x.type=="CallExpression" and #x.arguments==2 and x.arguments[1].type=="Identifier" and x.arguments[2].type=="StringLiteral" then blobs[#blobs+1]=x.arguments[2].value end
 end)
 if #funcs<12 then return nil,"MoonSec function layout was not found" end
 if #keys==0 then return nil,"MoonSec bytecode key was not found" end
 if #blobs==0 then return nil,"MoonSec bytecode blob was not found" end
 local c={order={},types={},ckey=0,bkey=0}
 local proto=funcs[9]
 for _,x in ipairs(proto.body) do
  if x.type=="AssignmentStatement" then c.order[#c.order+1]="params"
  elseif x.type=="NumericForStatement" then
   if #x.body==1 then c.order[#c.order+1]="functions"
   elseif #x.body==2 then c.order[#c.order+1]="instructions"
   elseif #x.body==4 then
    c.order[#c.order+1]="constants"
    local q=eqs(x)
    if #q<3 then return nil,"MoonSec constant tags were not found" end
    c.types[q[1]]="bool"
    c.types[q[2]]="number"
    c.types[q[3]]="string"
   end
  end
 end
 if #c.order~=4 then return nil,"MoonSec prototype layout was not found" end
 local vals={}
 for i,x in ipairs(keys) do
  local ok,v=pcall(eval.run,x,4000000)
  if not ok then return nil,v end
  vals[i]=math.floor(v)
 end
 if #vals==2 then c.ckey=vals[1] end
 c.bkey=vals[#vals]
 local raw,err=str.dec(blobs[#blobs],c.bkey)
 if not raw then return nil,err end
 local ok,root=pcall(deser.run,raw,c)
 if not ok then return nil,root end
 local names={}
 walk(ast,function(x)
  if x.type=="VariableDeclaration" and #x.variables==1 and #x.init==1 and x.init[1].type=="NumberLiteral" then
   local q=math.floor(x.init[1].value)
   local v=({[1]="OP_ENUM",[2]="OP_A",[3]="OP_B",[4]="OP_C"})[q]
   if v then names[x.variables[1].identifier.name]=v end
  elseif x.type=="VariableDeclaration" and #x.variables==1 and #x.init==1 and (x.init[1].type=="BinaryExpression" or x.init[1].type=="LogicalExpression") and x.init[1].left.type=="Identifier" and x.init[1].left.name=="unpack" then
   names[x.variables[1].identifier.name]="unpack"
  end
 end)
 local wrap=funcs[11]
 names[wrap.identifier.name]="wrap_proto"
 if wrap.parameters[1] then names[wrap.parameters[1].name]="proto" end
 if wrap.parameters[2] then names[wrap.parameters[2].name]="upv" end
 if wrap.parameters[3] then names[wrap.parameters[3].name]="env" end
 local direct={}
 for _,x in ipairs(funcs[12].body) do
  if x.type=="VariableDeclaration" then for _,q in ipairs(x.variables) do direct[#direct+1]=q.identifier.name end end
 end
 local cn={[1]="insts",[2]="protos",[3]="params",[5]="_R",[6]="pc",[7]="top",[8]="vararg",[9]="args",[10]="pcount",[11]="lupv",[12]="stk",[14]="varargz",[15]="inst",[16]="enum"}
 for i,v in pairs(cn) do if direct[i] then names[direct[i]]=v end end
 norm.ids(ast,names)
 return {ast=ast,funcs=funcs,ctx=c,root=root,bytes=#raw,names=names}
end

m.walk=walk
return m
