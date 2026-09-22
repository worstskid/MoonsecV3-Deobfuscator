--[=[ deobfuscated by sergei.dev @ .gg/svgmV95Apm ]=]--
local e=getfenv and getfenv() or _ENV
local q=table.unpack or unpack
local function z(...)return {n=select('#',...),...}end
local f={}
f[16] = function(u,...)
local r={}
local a=z(...)
for i=1,1 do r[i-1]=a[i] end
local top=0
local p=1
while true do
if p==1 then
r[0]=r[0][r[255]]
p=2
elseif p==2 then
local x=z(r[0](r[1]))
for i=1,764 do r[0+i-1]=x[i] end
p=3
else break end
end
end
f[15] = function(u,...)
local r={}
local a=z(...)
for i=1,0 do r[i-1]=a[i] end
local top=0
local p=1
while true do
if p==1 then
r[1]=r[0][1]
p=2
elseif p==2 then
r[1][1]=r[1]
p=3
elseif p==3 then
r[1][r[255]]=r[255]
p=4
elseif p==4 then
r[1][1]=r[1]
p=5
elseif p==5 then
r[0]=nil
p=6
else break end
end
end
f[14] = function(u,...)
local r={}
local a=z(...)
for i=1,5 do r[i-1]=a[i] end
local top=4
local p=1
while true do
if p==1 then
r[5]=u[1]
p=2
elseif p==2 then
r[5]=r[5][r[255]]
p=3
elseif p==3 then
r[5]=e["sub"]
p=4
elseif p==4 then
r[0]=r[5][r[255]]
p=5
elseif p==5 then
r[0]=r[8][r[255]]
p=6
elseif p==6 then
if ((r[5]==r[0])~=false) then p=8 else p=7 end
elseif p==7 then
r[5]["sub"]=r[0]
p=8
elseif p==8 then
local x=z(r[5]())
for i=1,x.n do r[5+i-1]=x[i] end
top=5+x.n-1
p=9
elseif p==9 then
r[6]=r[1];r[5]=r[1][r[255]]
p=10
elseif p==10 then
r[1]={}
p=11
elseif p==11 then
r[5][0]=r[255]
p=12
elseif p==12 then
r[6][1]=r[255]
p=13
elseif p==13 then
r[7][-1]=r[255]
p=14
elseif p==14 then
r[8]=256
p=15
elseif p==15 then
r[8],r[9],r[10]=r[8]()
p=16
elseif p==16 then
r[9][0]=r[0]
p=17
elseif p==17 then
r[10][""]=r[255]
p=18
elseif p==18 then
r[11]["sub"]=r[2]
p=19
elseif p==19 then
r[11]=e[2]
p=20
elseif p==20 then
r[0]=r[27][r[255]]
p=21
elseif p==21 then
r[12]=u[3]
p=22
elseif p==22 then
r[13]=r[1]["sub"]
p=23
elseif p==23 then
r[15]=e[0]
p=24
elseif p==24 then
r[16]=r[6][r[255]]
p=25
elseif p==25 then
r[13]=r[16][""]
p=26
elseif p==26 then
if ((r[12]==r[13])~=false) then p=28 else p=27 end
elseif p==27 then
r[9],r[10],r[11],r[12],r[13],r[14],r[15]=r[9](r[10],r[11],r[12],r[13],r[14],r[15],r[16],r[17],r[18],r[19],r[20])
p=28
elseif p==28 then
r[11],r[12],r[13],r[14],r[15],r[16]=r[11](r[12],r[13],r[14],r[15],r[16],r[17],r[18],r[19],r[20],r[21],r[22],r[23],r[24],r[25],r[26],r[27],r[28],r[29],r[30],r[31],r[32],r[33],r[34],r[35],r[36],r[37],r[38],r[39],r[40])
p=29
elseif p==29 then
p=31
elseif p==30 then
p=38
elseif p==31 then
r[12]=u[3]
p=32
elseif p==32 then
r[13]=r[1]["sub"]
p=33
elseif p==33 then
r[15]=e[0]
p=34
elseif p==34 then
r[16]=r[6][r[255]]
p=35
elseif p==35 then
r[13]=r[16][""]
p=36
elseif p==36 then
if ((r[12]==r[13])~=false) then p=38 else p=37 end
elseif p==37 then
r[9]=2+r[12]
p=38
elseif p==38 then
if ((r[11]==2)~=false) then p=40 else p=39 end
elseif p==39 then
p=56
elseif p==40 then
r[7]=r[7]+1
p=41
elseif p==41 then
p=4
elseif p==42 then
r[12]=e[1]
p=43
elseif p==43 then
r[13]=r[12];r[12]=r[12][1]
p=44
elseif p==44 then
r[13]=-1
p=45
elseif p==45 then
r[14],r[15],r[16],r[17]=r[14]()
p=46
elseif p==46 then
r[16]=r[12][r[255]]
p=47
elseif p==47 then
r[17]=r[12][r[255]]
p=48
elseif p==48 then
r[15]=r[17];r[14]=r[17][""]
p=49
elseif p==49 then
r[13]=r[13]%16
p=50
elseif p==50 then
p=10
elseif p==51 then
local x=z(r[14](r[15],r[16],r[17],r[18],r[19],r[20],r[21],r[22],r[23]))
for i=1,x.n do r[14+i-1]=x[i] end
top=14+x.n-1
p=52
elseif p==52 then
r[15]=r[3]+r[255]
p=53
elseif p==53 then
r[16][16]=r[1]
p=54
elseif p==54 then
r[15]=e[16]
p=55
elseif p==55 then
r[10]=r[14][16]
p=56
elseif p==56 then
r[6]=r[60][16]
p=57
elseif p==57 then
r[0][r[264]]=r[0]
p=58
elseif p==58 then
r[12][r[255]]=r[255]
p=59
elseif p==59 then
r[12]=e[nil]
p=60
elseif p==60 then
r[10]=e[""]
p=61
elseif p==61 then
r[6]=r[5];r[5]=r[5][1]
p=62
elseif p==62 then
r[6]=0
p=63
elseif p==63 then
local x=z(r[0](r[1],r[2],r[3],r[4],r[5],r[6],r[7],r[8],r[9],r[10],r[11],r[12],r[13],r[14],r[15],r[16],r[17]))
for i=1,x.n do r[0+i-1]=x[i] end
top=0+x.n-1
p=64
elseif p==64 then
r[1]=r[1];r[0]=r[1][r[264]]
p=65
else break end
end
end
f[13] = function(u,...)
local r={}
local a=z(...)
for i=1,0 do r[i-1]=a[i] end
local top=0
local p=1
while true do
if p==1 then
r[0]=u[2]
p=2
elseif p==2 then
r[0]=r[0][r[255]]
p=3
elseif p==3 then
r[0]=r[1][r[256]]
p=4
else break end
end
end
f[12] = function(u,...)
local r={}
local a=z(...)
for i=1,0 do r[i-1]=a[i] end
local top=0
local p=1
while true do
if p==1 then
r[0]=u[2]
p=2
elseif p==2 then
r[0]=r[0][r[255]]
p=3
elseif p==3 then
r[0]=r[1][r[256]]
p=4
else break end
end
end
f[11] = function(u,...)
local r={}
local a=z(...)
for i=1,1 do r[i-1]=a[i] end
local top=0
local p=1
while true do
if p==1 then
r[1]=u[2]
p=2
elseif p==2 then
r[1]=r[0][r[255]]
p=3
elseif p==3 then
r[0]=r[1][r[255]]
p=4
elseif p==4 then
r[0]=r[1][r[256]]
p=5
else break end
end
end
f[10] = function(u,...)
local r={}
local a=z(...)
for i=1,1 do r[i-1]=a[i] end
local top=0
local p=1
while true do
if p==1 then
r[1]=u[2]
p=2
elseif p==2 then
r[1]=r[0][r[255]]
p=3
elseif p==3 then
r[0]=r[1][r[255]]
p=4
elseif p==4 then
r[0]=r[1][r[256]]
p=5
else break end
end
end
f[9] = function(u,...)
local r={}
local a=z(...)
for i=1,2 do r[i-1]=a[i] end
local top=1
local p=1
while true do
if p==1 then
r[2]["pcall"]=r[255]
p=2
elseif p==2 then
r[3][r[255]]=r[255]
p=3
elseif p==3 then
r[4]["string"]=r[255]
p=4
elseif p==4 then
r[3][2]=r[4]
p=5
elseif p==5 then
r[4][r[255]]=r[255]
p=6
elseif p==6 then
r[4]={}
p=7
elseif p==7 then
r[5][r[255]]=r[255]
p=8
elseif p==8 then
r[2]=r[5]+1
p=9
elseif p==9 then
u[13]=r[2]
p=10
elseif p==10 then
r[0]=u[13]
p=11
elseif p==11 then
r[3][r[1]]=r[255]
p=12
elseif p==12 then
r[3]=1
p=13
elseif p==13 then
u[9]=r[3]
p=14
elseif p==14 then
r[4]={}
p=15
elseif p==15 then
if ((r[3]==1)~=false) then p=17 else p=16 end
elseif p==16 then
if ((r[3]=="string")~=false) then p=18 else p=17 end
elseif p==17 then
p=48
elseif p==18 then
r[3]=u[1]
p=19
elseif p==19 then
r[3]=r[3]["string"]
p=20
elseif p==20 then
r[3]=e["setmetatable"]
p=21
elseif p==21 then
r[0]=r[22][r[255]]
p=22
elseif p==22 then
r[0]=r[24][r[255]]
p=23
elseif p==23 then
if ((r[3]==r[0])~=false) then p=25 else p=24 end
elseif p==24 then
r[3]=e[1]
p=25
elseif p==25 then
r[4]=r[0];r[3]=r[0][r[255]]
p=26
elseif p==26 then
r[3]=2
p=27
elseif p==27 then
local x=z(r[4]())
for i=1,x.n do r[4+i-1]=x[i] end
top=4+x.n-1
p=28
elseif p==28 then
r[5]=r[0][r[255]]
p=29
elseif p==29 then
r[6]=r[0]["string"]
p=30
elseif p==30 then
r[1]=r[4];r[0]=r[4][r[255]]
p=31
elseif p==31 then
p=2
elseif p==32 then
r[5]["setmetatable"]=r[0]
p=33
elseif p==33 then
r[6]=e["table"]
p=34
elseif p==34 then
r[7]=r[0]["string"]
p=35
elseif p==35 then
r[8]=r[3]["string"]
p=36
elseif p==36 then
r[0]["table"]=r[0]
p=37
elseif p==37 then
r[7]["__tostring"]="type"
p=38
elseif p==38 then
r[5]=e["__tostring"]
p=39
elseif p==39 then
r[6]="pcall"
p=40
elseif p==40 then
local x=z(r[7]())
for i=1,x.n do r[7+i-1]=x[i] end
top=7+x.n-1
p=41
elseif p==41 then
r[7]["__tostring"]=r[0]
p=42
elseif p==42 then
r[8]=e["setmetatable"]
p=43
elseif p==43 then
r[6]=r[8]["string"]
p=44
elseif p==44 then
r[6]=r[0][r[255]]
p=45
elseif p==45 then
r[6]["string"]=r[3]
p=46
elseif p==46 then
r[4]=e[1]
p=47
elseif p==47 then
r[4]=r[0];r[3]=r[0][r[255]]
p=48
elseif p==48 then
r[3]="type"
p=49
elseif p==49 then
local x=z(r[4]())
for i=1,x.n do r[4+i-1]=x[i] end
top=4+x.n-1
p=50
elseif p==50 then
r[3]=r[2][1]
p=51
elseif p==51 then
r[3]=r[84]["table"]
p=52
elseif p==52 then
r[1]=r[84];r[0]=r[84][r[255]]
p=53
elseif p==53 then
r[3]=u[1]
p=54
elseif p==54 then
r[4]=r[1][1]
p=55
elseif p==55 then
r[3]=e[2]
p=56
elseif p==56 then
r[4]=r[1][2]
p=57
elseif p==57 then
r[3]=r[3]["table"]
p=58
elseif p==58 then
if ((r[4]==r[0])~=false) then p=60 else p=59 end
elseif p==59 then
r[5]=r[0][r[255]]
p=60
elseif p==60 then
r[6]["string"]=r[2]
p=61
elseif p==61 then
r[5]["setmetatable"]="pcall"
p=62
elseif p==62 then
r[6]["string"]=r[3]
p=63
elseif p==63 then
r[7]=e["string"]
p=64
elseif p==64 then
r[0]=r[4][r[255]]
p=65
elseif p==65 then
r[5]="pcall"
p=66
elseif p==66 then
r[5]["setmetatable"]=r[0]
p=67
elseif p==67 then
r[6]=e["table"]
p=68
elseif p==68 then
r[7]=r[0]["string"]
p=69
elseif p==69 then
r[8]=r[2]["string"]
p=70
elseif p==70 then
r[0]["table"]=r[0]
p=71
elseif p==71 then
r[7]["__tostring"]="type"
p=72
elseif p==72 then
r[5]=e["__tostring"]
p=73
elseif p==73 then
r[6]=r[6]+r[255]
p=74
elseif p==74 then
local x=z(r[7](q(r,8,top)))
for i=1,x.n do r[7+i-1]=x[i] end
top=7+x.n-1
p=75
elseif p==75 then
p=8
elseif p==76 then
r[8]=r[5][r[0]]
p=77
elseif p==77 then
r[6]=u[9]
p=78
elseif p==78 then
r[6]=r[0][r[0]]
p=79
elseif p==79 then
r[7]=u[2]
p=80
elseif p==80 then
r[6]=r[6][r[7]]
p=81
elseif p==81 then
r[7]=r[1][r[3]]
p=82
elseif p==82 then
r[6]=u[8]
p=83
elseif p==83 then
r[4]=r[2][r[255]]
p=84
elseif p==84 then
r[3][r[255]]=r[0]
p=85
elseif p==85 then
r[0][r[254]]=r[264]
p=86
else break end
end
end
f[8] = function(u,...)
local r={}
local a=z(...)
for i=1,0 do r[i-1]=a[i] end
local top=0
local p=1
while true do
if p==1 then
r[1]=r[0][1]
p=2
elseif p==2 then
r[1][1]=r[1]
p=3
elseif p==3 then
r[1][r[255]]=r[255]
p=4
elseif p==4 then
r[1][1]=r[1]
p=5
elseif p==5 then
r[0]=nil
p=6
else break end
end
end
f[7] = function(u,...)
local r={}
local a=z(...)
for i=1,1 do r[i-1]=a[i] end
local top=0
local p=1
while true do
if p==1 then
if ((r[0]=="")~=false) then p=3 else p=2 end
elseif p==2 then
p=6
elseif p==3 then
r[1]["mzMQlSMrXmu_OkD"]=r[0]
p=4
elseif p==4 then
r[1]=e[""]
p=5
elseif p==5 then
r[0]=r[7][r[255]]
p=6
elseif p==6 then
r[1]=r[1][r[255]]
p=7
elseif p==7 then
r[1][""]=r[0]
p=8
elseif p==8 then
r[0]=e[nil]
p=9
else break end
end
end
f[6] = function(u,...)
local r={}
local a=z(...)
for i=1,2 do r[i-1]=a[i] end
local top=1
local p=1
while true do
if p==1 then
if r[2] then p=2 else p=3 end
elseif p==2 then
r[3]=r[256]+r[0]
p=3
elseif p==3 then
r[4]=r[256]+r[0]
p=4
elseif p==4 then
p=3
elseif p==5 then
local m=100
for i=1,top-2 do r[2][m+i]=r[2+i] end
p=6
elseif p==6 then
r[0][r[1]]=r[0]
p=7
else break end
end
end
f[5] = function(u,...)
local r={}
local a=z(...)
for i=1,1 do r[i-1]=a[i] end
local top=0
local p=1
while true do
if p==1 then
r[1]=u[1]
p=2
elseif p==2 then
r[2]=r[0][r[255]]
p=3
elseif p==3 then
r[1]=e[2]
p=4
elseif p==4 then
r[1]=r[12]["table"]
p=5
elseif p==5 then
r[0]=r[12][r[255]]
p=6
elseif p==6 then
if ((r[1]==r[0])~=false) then p=8 else p=7 end
elseif p==7 then
r[2][r[255]]=r[0]
p=8
elseif p==8 then
r[3]=e["string"]
p=9
elseif p==9 then
r[0]=r[0][r[255]]
p=10
elseif p==10 then
r[0]=2
p=11
elseif p==11 then
r[1](r[2],r[3])
p=12
elseif p==12 then
r[0]["string"]=r[255]
p=13
elseif p==13 then
r[1]=e["string"]
p=14
elseif p==14 then
r[2][r[255]]=r[0]
p=15
elseif p==15 then
r[1]=e[2]
p=16
elseif p==16 then
r[1]=r[49]["string"]
p=17
elseif p==17 then
r[0]="string"
p=18
elseif p==18 then
local x=z(r[1](q(r,2,top)))
for i=1,x.n do r[1+i-1]=x[i] end
top=1+x.n-1
p=19
elseif p==19 then
r[5][1]="string"
p=20
elseif p==20 then
r[0]=e[1]
p=21
elseif p==21 then
p=50
elseif p==22 then
r[1]=u[4]
p=23
elseif p==23 then
r[2]=r[0][r[255]]
p=24
elseif p==24 then
r[3]=e[1]
p=25
elseif p==25 then
r[4]=r[5][r[255]]
p=26
elseif p==26 then
r[1]=r[4][2]
p=27
elseif p==27 then
if ((r[1]==r[6])~=false) then p=29 else p=28 end
elseif p==28 then
p=50
elseif p==29 then
r[1]=e[""]
p=30
elseif p==30 then
r[2]=r[2][r[255]]
p=31
elseif p==31 then
r[3]=r[0][r[255]]
p=32
elseif p==32 then
r[4]=r[5][r[255]]
p=33
elseif p==33 then
r[2]=r[48][r[255]]
p=34
elseif p==34 then
r[6]=e["string"]
p=35
elseif p==35 then
r[7]=r[4][r[255]]
p=36
elseif p==36 then
if r[8] then p=37 else p=38 end
elseif p==37 then
if r[9] then p=38 else p=39 end
elseif p==38 then
r[10]=r[0][r[255]]
p=39
elseif p==39 then
r[11][1]=r[0]
p=40
elseif p==40 then
r[12][1]=r[255]
p=41
elseif p==41 then
r[9][r[261]]=r[2]
p=42
elseif p==42 then
r[8]=e[nil]
p=43
elseif p==43 then
r[9]=r[5][r[255]]
p=44
elseif p==44 then
r[8]=nil
p=45
elseif p==45 then
r[8]=r[261]+r[4]
p=46
elseif p==46 then
r[7]=""
p=47
elseif p==47 then
r[1],r[2],r[3],r[4],r[5],r[6]=r[1](r[2],r[3],r[4],r[5],r[6])
p=48
elseif p==48 then
r[2][r[261]]=r[0]
p=49
elseif p==49 then
r[1]=e[2]
p=50
elseif p==50 then
r[0]=r[2][r[255]]
p=51
elseif p==51 then
r[0]["string"]=r[255]
p=52
else break end
end
end
f[4] = function(u,...)
local r={}
local a=z(...)
for i=1,0 do r[i-1]=a[i] end
local top=0
local p=1
while true do
if p==1 then
r[1]=r[0][1]
p=2
elseif p==2 then
r[1][1]=r[1]
p=3
elseif p==3 then
r[1][r[255]]=r[255]
p=4
elseif p==4 then
r[1][1]=r[1]
p=5
elseif p==5 then
r[0]=nil
p=6
else break end
end
end
f[3] = function(u,...)
local r={}
local a=z(...)
for i=1,0 do r[i-1]=a[i] end
local top=0
local p=1
while true do
if p==1 then
r[1]=r[0][1]
p=2
elseif p==2 then
r[1][1]=r[1]
p=3
elseif p==3 then
r[1][r[255]]=r[255]
p=4
elseif p==4 then
r[1][1]=r[1]
p=5
elseif p==5 then
r[0]=nil
p=6
else break end
end
end
f[2] = function(u,...)
local r={}
local a=z(...)
for i=1,0 do r[i-1]=a[i] end
local top=0
local p=1
while true do
if p==1 then
r[0]=r[0][r[255]]
p=2
elseif p==2 then
r[1]=u[2]
p=3
elseif p==3 then
r[2]=r[2][r[255]]
p=4
elseif p==4 then
r[1]=r[1]()
p=5
elseif p==5 then
r[0]=u[2]
p=6
elseif p==6 then
r[0]=r[0][r[255]]
p=7
elseif p==7 then
r[0]=u[3]
p=8
else break end
end
end
f[1] = function(u,...)
local r={}
local a=z(...)
for i=1,0 do r[i-1]=a[i] end
local top=0
local p=1
while true do
if p==1 then
local v={}
r[0] = function(...)return f[2](v,...)end
p=2
elseif p==2 then
r[1]=r[1]+r[255]
p=3
elseif p==3 then
r[2]=r[2]+r[255]
p=4
elseif p==4 then
r[1]="tXvbuoHmlHHc"
p=5
elseif p==5 then
r[0]=0
p=6
elseif p==6 then
local x=z(r[0](r[1],r[2],r[3],r[4],r[5],r[6],r[7],r[8]))
for i=1,x.n do r[0+i-1]=x[i] end
top=0+x.n-1
p=7
elseif p==7 then
r[0]["pcall"]=r[0]
p=8
elseif p==8 then
r[0]=e["pcall"]
p=9
elseif p==9 then
r[0]=r[0][r[255]]
p=10
elseif p==10 then
r[1]="pcall"
p=11
elseif p==11 then
r[2]=r[0][1]
p=12
elseif p==12 then
r[0]=r[3][r[255]]
p=13
elseif p==13 then
r[1]=r[1];r[0]=r[1][r[255]]
p=14
elseif p==14 then
r[0]=0
p=15
elseif p==15 then
local x=z(r[1](r[2]))
for i=1,x.n do r[1+i-1]=x[i] end
top=1+x.n-1
p=16
elseif p==16 then
r[0](q(r,1,top))
p=17
elseif p==17 then
r[0],r[1]=r[0](q(r,1,top))
p=18
elseif p==18 then
p=31
elseif p==19 then
p=31
elseif p==20 then
r[0]=e[0]
p=21
elseif p==21 then
r[0]=r[4][r[255]]
p=22
elseif p==22 then
r[0]=r[5][r[255]]
p=23
elseif p==23 then
r[1]=r[6][r[255]]
p=24
elseif p==24 then
r[0]=r[2]["tXvbuoHmlHHc"]
p=25
elseif p==25 then
r[0]=e["tXvbuoHmlHHc"]
p=26
elseif p==26 then
r[0]=r[1]["tXvbuoHmlHHc"]
p=27
elseif p==27 then
if ((r[0]==r[255])~=true) then p=29 else p=28 end
elseif p==28 then
r[0]=r[0][r[255]]
p=29
elseif p==29 then
r[1]="tXvbuoHmlHHc"
p=30
elseif p==30 then
r[1]="tXvbuoHmlHHc"
p=31
elseif p==31 then
r[0]=e[nil]
p=32
else break end
end
end
f[0] = function(u,...)
local r={}
local a=z(...)
for i=1,0 do r[i-1]=a[i] end
local top=0
local p=1
while true do
if p==1 then
r[0]=u[50]
p=2
elseif p==2 then
r[0]=r[47][r[255]]
p=3
elseif p==3 then
r[0]=u[48]
p=4
elseif p==4 then
r[0]=r[0][r[255]]
p=5
elseif p==5 then
r[1]=u[1]
p=6
elseif p==6 then
r[0]=r[0]["mVhdXUiDtBfsciSoi"]
p=7
elseif p==7 then
r[0]=u[1]
p=8
elseif p==8 then
r[1]=e[0]
p=9
elseif p==9 then
r[2]=e["SeCWCeufiHTWrQY"]
p=10
elseif p==10 then
r[3](r[4],r[5],r[6],r[7],r[8],r[9],r[10])
p=11
elseif p==11 then
r[0]=r[1][r[255]]
p=12
elseif p==12 then
r[2]=e["ù{î—í#œD\031iÓ"]
p=13
elseif p==13 then
r[2]=r[5]
p=14
elseif p==14 then
r[3]=true
p=15
elseif p==15 then
r[3],r[4],r[5],r[6],r[7],r[8],r[9],r[10],r[11],r[12],r[13],r[14],r[15]=r[3]()
p=16
elseif p==16 then
r[4]=e["table"]
p=17
elseif p==17 then
r[4]=r[4][r[65]]
p=18
elseif p==18 then
r[5]=r[41][r[0]]
p=19
elseif p==19 then
for i=5,5 do r[i]=nil end
p=20
elseif p==20 then
r[6]={}
p=21
elseif p==21 then
r[6]=u[7]
p=22
elseif p==22 then
r[7]=r[0][r[255]]
p=23
elseif p==23 then
r[8]={}
p=24
elseif p==24 then
r[9]={}
p=25
elseif p==25 then
r[10]=r[72]
p=26
elseif p==26 then
local x=z(r[8](r[9],r[10],r[11],r[12],r[13],r[14],r[15],r[16],r[17],r[18],r[19],r[20],r[21],r[22],r[23],r[24],r[25],r[26],r[27],r[28],r[29],r[30],r[31],r[32],r[33],r[34],r[35],r[36],r[37],r[38],r[39]))
for i=1,x.n do r[8+i-1]=x[i] end
top=8+x.n-1
p=27
elseif p==27 then
r[12][r[5]]=r[0]
p=28
elseif p==28 then
r[13][r[11]]=r[0]
p=29
elseif p==29 then
r[12]=e["ù{î—í#œD\031iÓ"]
p=30
elseif p==30 then
r[8]=r[11];r[7]=r[11][" 5\011Üø\"lÊBmß¹,ÐXÉ\014”"]
p=31
elseif p==31 then
r[7]=" 5\011Üø\"lÊBmß¹,ÐXÉ\014”"
p=32
elseif p==32 then
local x=z(r[8](r[9],r[10],r[11],r[12],r[13],r[14],r[15],r[16],r[17],r[18],r[19],r[20],r[21],r[22],r[23],r[24],r[25],r[26]))
for i=1,x.n do r[8+i-1]=x[i] end
top=8+x.n-1
p=33
elseif p==33 then
r[8]=r[8][r[255]]
p=34
elseif p==34 then
r[8]=r[2][18]
p=35
elseif p==35 then
r[1]=r[2];r[0]=r[2][r[255]]
p=36
elseif p==36 then
r[0]=9
p=37
elseif p==37 then
r[0]=3
p=38
elseif p==38 then
r[0]="table"
p=39
elseif p==39 then
r[0]="´Úóç"
p=40
elseif p==40 then
r[0]="mVhdXUiDtBfsciSoi"
p=41
elseif p==41 then
r[9]=e[3]
p=42
elseif p==42 then
r[10]=u[1]
p=43
elseif p==43 then
r[10]=r[2];r[9]=r[2]["ù{î—í#œD\031iÓ"]
p=44
elseif p==44 then
local x=z(r[0](r[1],r[2],r[3],r[4],r[5],r[6],r[7],r[8],r[9]))
for i=1,x.n do r[0+i-1]=x[i] end
top=0+x.n-1
p=45
elseif p==45 then
r[0]=r[0](r[1])
p=46
elseif p==46 then
p=1
elseif p==47 then
p=335
elseif p==48 then
r[0]["YQrWTHifueCWCeS"]=r[0]
p=49
elseif p==49 then
r[0]=e["print"]
p=50
elseif p==50 then
r[0]=r[32][r[255]]
p=51
elseif p==51 then
r[0]=r[23][r[255]]
p=52
elseif p==52 then
r[0][r[255]]=r[38]
p=53
elseif p==53 then
r[0]["print"]=r[255]
p=54
elseif p==54 then
r[0]=e["mVhdXUiDtBfsciSoi"]
p=55
elseif p==55 then
r[0]="MoonSec_StringsHiddenAttr"+r[0]
p=56
elseif p==56 then
r[0]["ZxohVjXPqewjecZlUg_pilhKXXdDcZFH"]=r[0]
p=57
elseif p==57 then
r[1]=e["print"]
p=58
elseif p==58 then
r[2]=r[0][r[255]]
p=59
elseif p==59 then
r[3]=r[0][r[255]]
p=60
elseif p==60 then
r[4]["u<e2 af6jUZmBrcN"]=r[0]
p=61
elseif p==61 then
r[5][0]=r[255]
p=62
elseif p==62 then
r[6]=e[255]
p=63
elseif p==63 then
r[7]=r[72][r[0]]
p=64
elseif p==64 then
r[5]=u[73]
p=65
elseif p==65 then
r[9]=r[54][r[0]]
p=66
elseif p==66 then
r[9]=u[10]
p=67
elseif p==67 then
r[10]=r[8][r[0]]
p=68
elseif p==68 then
r[9]=r[2][r[2]]
p=69
elseif p==69 then
r[2]=u[9]
p=70
elseif p==70 then
r[9],r[10],r[11],r[12],r[13],r[14],r[15]=r[9](r[10])
p=71
elseif p==71 then
r[2],r[3],r[4],r[5],r[6],r[7],r[8]=r[2](r[3],r[4],r[5],r[6],r[7],r[8],r[9],r[10])
p=72
elseif p==72 then
p=65
elseif p==73 then
r[5]=e[1]
p=74
elseif p==74 then
r[6]=r[77][r[255]]
p=75
elseif p==75 then
r[7]=r[72][r[255]]
p=76
elseif p==76 then
r[5]=r[89][r[255]]
p=77
elseif p==77 then
r[9]=r[8][1]
p=78
elseif p==78 then
r[10]=e[9]
p=79
elseif p==79 then
r[12]=r[8][r[255]]
p=80
elseif p==80 then
local x=z(r[13]())
for i=1,x.n do r[13+i-1]=x[i] end
top=13+x.n-1
p=81
elseif p==81 then
r[11]=r[13];r[10]=r[13]["ù{î—í#œD\031iÓ"]
p=82
elseif p==82 then
r[3]=15
p=83
elseif p==83 then
r[9],r[10],r[11],r[12],r[13],r[14],r[15],r[16],r[17],r[18],r[19],r[20],r[21],r[22],r[23],r[24],r[25],r[26],r[27],r[28],r[29],r[30],r[31],r[32],r[33],r[34],r[35],r[36],r[37],r[38],r[39],r[40],r[41],r[42],r[43],r[44],r[45],r[46],r[47],r[48],r[49],r[50],r[51],r[52],r[53],r[54],r[55],r[56],r[57],r[58],r[59],r[60],r[61],r[62],r[63],r[64],r[65],r[66],r[67],r[68],r[69]=r[9]()
p=84
elseif p==84 then
r[12]=r[8];r[11]=r[8][r[255]]
p=85
elseif p==85 then
r[12]=3
p=86
elseif p==86 then
r[9]=r[9](r[10],r[11],r[12])
p=87
elseif p==87 then
local x=z(r[10](r[11],r[12],r[13],r[14],r[15],r[16],r[17]))
for i=1,71 do r[10+i-1]=x[i] end
p=88
elseif p==88 then
r[3]=e[15]
p=89
elseif p==89 then
r[6]=r[76];r[5]=r[76][r[255]]
p=90
elseif p==90 then
r[5]=18
p=91
elseif p==91 then
local x=z(r[0](r[1]))
for i=1,x.n do r[0+i-1]=x[i] end
top=0+x.n-1
p=92
elseif p==92 then
r[0]=r[0][r[255]]
p=93
elseif p==93 then
r[0]=r[3][r[255]]
p=94
elseif p==94 then
r[1]=r[2];r[0]=r[2][r[255]]
p=95
elseif p==95 then
r[6]=u[61]
p=96
elseif p==96 then
r[6]=r[101][r[255]]
p=97
elseif p==97 then
r[0]=u[102]
p=98
elseif p==98 then
r[6]=r[60][r[255]]
p=99
elseif p==99 then
r[6]=u[2]
p=100
elseif p==100 then
r[6]=r[102]["mVhdXUiDtBfsciSoi"]
p=101
elseif p==101 then
r[0]=u[103]
p=102
elseif p==102 then
r[6]["OHRRHLbPUudmdxuD"]=r[0]
p=103
elseif p==103 then
r[7]=e["type"]
p=104
elseif p==104 then
r[8]=r[79][r[255]]
p=105
elseif p==105 then
r[9]=r[72][r[255]]
p=106
elseif p==106 then
r[10][4]=r[0]
p=107
elseif p==107 then
r[11]["²OâaÞ"]=r[255]
p=108
elseif p==108 then
r[12]=e[47]
p=109
elseif p==109 then
r[7]=r[7](r[8],r[9],r[10],r[11],r[12])
p=110
elseif p==110 then
r[9]=r[5];r[8]=r[5][r[255]]
p=111
elseif p==111 then
r[9]="\025Q«)"
p=112
elseif p==112 then
local x=z(r[10](r[11],r[12],r[13],r[14],r[15],r[16],r[17],r[18],r[19],r[20],r[21],r[22],r[23],r[24],r[25],r[26],r[27],r[28],r[29],r[30],r[31],r[32],r[33],r[34],r[35],r[36],r[37],r[38]))
for i=1,x.n do r[10+i-1]=x[i] end
top=10+x.n-1
p=113
elseif p==113 then
r[12]=r[22];r[11]=r[22][r[255]]
p=114
elseif p==114 then
r[12]="bµ…ècšº"
p=115
elseif p==115 then
local x=z(r[13]())
for i=1,x.n do r[13+i-1]=x[i] end
top=13+x.n-1
p=116
elseif p==116 then
r[8]="‘\006±Y"
p=117
elseif p==117 then
local x=z(r[9]())
for i=1,x.n do r[9+i-1]=x[i] end
top=9+x.n-1
p=118
elseif p==118 then
r[10]["“Ê\\Þ"]=r[0]
p=119
elseif p==119 then
r[11][3]=r[255]
p=120
elseif p==120 then
r[12][8]=r[0]
p=121
elseif p==121 then
r[13]=e["úïF6sœÂ\003.­"]
p=122
elseif p==122 then
r[14]=r[11][r[255]]
p=123
elseif p==123 then
r[9]="sub"
p=124
elseif p==124 then
local x=z(r[10]())
for i=1,x.n do r[10+i-1]=x[i] end
top=10+x.n-1
p=125
elseif p==125 then
r[11]["qW:\025"]=r[0]
p=126
elseif p==126 then
r[12]=e[4]
p=127
elseif p==127 then
r[13]=r[34][r[255]]
p=128
elseif p==128 then
r[14]=r[57][r[255]]
p=129
elseif p==129 then
r[15][18]=r[0]
p=130
elseif p==130 then
r[10]=r[10](r[11],r[12],r[13],r[14],r[15],r[16],r[17],r[18],r[19],r[20],r[21],r[22],r[23],r[24])
p=131
elseif p==131 then
r[11]["ù{î—í#œD\031iÓ"]=r[0]
p=132
elseif p==132 then
r[12]=e["type"]
p=133
elseif p==133 then
r[13]=r[69][r[255]]
p=134
elseif p==134 then
r[14]=r[22][r[255]]
p=135
elseif p==135 then
r[15][6]=r[0]
p=136
elseif p==136 then
r[16]["‰#JcÕêÛÊ"]=r[255]
p=137
elseif p==137 then
r[17]=e[47]
p=138
elseif p==138 then
r[12]=r[17]["ù{î—í#œD\031iÓ"]
p=139
elseif p==139 then
r[13]["type"]=r[0]
p=140
elseif p==140 then
r[14]["†‡†*"]=r[255]
p=141
elseif p==141 then
r[15][6]=r[0]
p=142
elseif p==142 then
r[16]=e[8]
p=143
elseif p==143 then
r[17]=r[12][r[255]]
p=144
elseif p==144 then
r[18]=22
p=145
elseif p==145 then
r[13]=r[13](r[14],r[15],r[16],r[17],r[18],r[19],r[20],r[21],r[22],r[23],r[24],r[25],r[26],r[27],r[28],r[29],r[30])
p=146
elseif p==146 then
r[11](r[12],r[13],r[14],r[15],r[16],r[17],r[18],r[19],r[20],r[21],r[22],r[23])
p=147
elseif p==147 then
p=54
elseif p==148 then
r[13]=e["type"]
p=149
elseif p==149 then
r[14]=r[7][r[255]]
p=150
elseif p==150 then
r[15]=r[17][r[255]]
p=151
elseif p==151 then
r[16]=r[8][r[255]]
p=152
elseif p==152 then
r[17]="\rœ>0Y9Ë~ÉñáÊ¢"
p=153
elseif p==153 then
r[18]=nil
p=154
elseif p==154 then
if ((r[13]=="ù{î—í#œD\031iÓ")~=true) then p=156 else p=155 end
elseif p==155 then
r[13][18]=r[13]
p=156
elseif p==156 then
local x=z(r[14](r[15],r[16],r[17],r[18],r[19],r[20],r[21],r[22],r[23],r[24],r[25],r[26],r[27],r[28],r[29],r[30],r[31]))
for i=1,x.n do r[14+i-1]=x[i] end
top=14+x.n-1
p=157
elseif p==157 then
r[16]=r[76];r[15]=r[76][r[255]]
p=158
elseif p==158 then
r[16]={}
p=159
elseif p==159 then
r[16][10]=r[255]
p=160
elseif p==160 then
r[0][10]=r[255]
p=161
elseif p==161 then
r[16][1]=r[255]
p=162
elseif p==162 then
r[17][10]=r[255]
p=163
elseif p==163 then
r[18]=r[72]+r[255]
p=164
elseif p==164 then
r[16]=r[187]+r[255]
p=165
elseif p==165 then
r[20][10]=r[19]
p=166
elseif p==166 then
r[20],r[21],r[22],r[23],r[24],r[25],r[26],r[27],r[28],r[29],r[30],r[31],r[32],r[33],r[34],r[35],r[36],r[37],r[38]=r[20]()
p=167
elseif p==167 then
r[21]=r[186];r[20]=r[186][r[255]]
p=168
elseif p==168 then
r[0]={}
p=169
elseif p==169 then
r[20][18]="´Úóç"
p=170
elseif p==170 then
r[20][12]=3
p=171
elseif p==171 then
r[21][10]="ve’n\023\rz"
p=172
elseif p==172 then
r[21]=e[18]
p=173
elseif p==173 then
r[21]=r[2];r[20]=r[2]["ù{î—í#œD\031iÓ"]
p=174
elseif p==174 then
r[20]=12
p=175
elseif p==175 then
local x=z(r[20]())
for i=1,x.n do r[20+i-1]=x[i] end
top=20+x.n-1
p=176
elseif p==176 then
r[20]=r[186][3]
p=177
elseif p==177 then
r[0]=r[186][r[255]]
p=178
elseif p==178 then
r[21]=r[13];r[20]=r[13][r[255]]
p=179
elseif p==179 then
r[21]=e[" 5\011Üø\"lÊBmß¹,ÐXÉ\014”"]
p=180
elseif p==180 then
r[20]=r[2]["mVhdXUiDtBfsciSoi"]
p=181
elseif p==181 then
r[20]=r[33][r[255]]
p=182
elseif p==182 then
r[20]["mVhdXUiDtBfsciSoi"]=r[1]
p=183
elseif p==183 then
r[0]=e["mVhdXUiDtBfsciSoi"]
p=184
elseif p==184 then
r[20]=r[20][r[255]]
p=185
elseif p==185 then
r[21]="´Úóç"
p=186
elseif p==186 then
r[21]=r[1]["mVhdXUiDtBfsciSoi"]
p=187
elseif p==187 then
r[16]=r[164][r[255]]
p=188
elseif p==188 then
r[14]=r[14][1]
p=189
elseif p==189 then
r[16]="type"
p=190
elseif p==190 then
local x=z(r[17](r[18],r[19],r[20],r[21],r[22],r[23],r[24],r[25],r[26]))
for i=1,x.n do r[17+i-1]=x[i] end
top=17+x.n-1
p=191
elseif p==191 then
r[18]=e[8]
p=192
elseif p==192 then
r[19]=r[22][r[255]]
p=193
elseif p==193 then
if r[20] then p=194 else p=195 end
elseif p==194 then
r[21]=53+r[0]
p=195
elseif p==195 then
r[16]="‰#JcÕêÛÊ"+r[2]
p=196
elseif p==196 then
r[8]=r[16]
p=197
elseif p==197 then
local x=z(r[16](r[17],r[18],r[19],r[20]))
for i=1,x.n do r[16+i-1]=x[i] end
top=16+x.n-1
p=198
elseif p==198 then
r[17][r[48]]=r[0]
p=199
elseif p==199 then
r[18][r[4]]=r[0]
p=200
elseif p==200 then
r[19]=8+r[0]
p=201
elseif p==201 then
p=74
elseif p==202 then
r[21]=r[64]+r[255]
p=203
elseif p==203 then
r[16]="‰#JcÕêÛÊ"
p=204
elseif p==204 then
r[9]=31
p=205
elseif p==205 then
r[16],r[17],r[18],r[19],r[20],r[21],r[22]=r[16]()
p=206
elseif p==206 then
r[7]["YSB\030\004ò\"†y\012\\ f"]=r[16]
p=207
elseif p==207 then
r[0]=e["YSB\030\004ò\"†y\012\\ f"]
p=208
elseif p==208 then
r[16]=r[6]["´Úóç"]
p=209
elseif p==209 then
r[7]=31
p=210
elseif p==210 then
r[16][18]=r[9]
p=211
elseif p==211 then
r[8],r[9],r[10],r[11],r[12],r[13],r[14],r[15],r[16],r[17],r[18],r[19],r[20],r[21],r[22]=r[8](q(r,9,220))
p=212
elseif p==212 then
r[1]=r[220];r[0]=r[220][r[255]]
p=213
elseif p==213 then
r[16]={}
p=214
elseif p==214 then
r[17]["‘\006±Y"]=r[255]
p=215
elseif p==215 then
r[18][10]=r[255]
p=216
elseif p==216 then
r[19][8]=r[255]
p=217
elseif p==217 then
r[20]["YSB\030\004ò\"†y\012\\ f"]=r[0]
p=218
elseif p==218 then
r[21]=e[27]
p=219
elseif p==219 then
r[16]=r[21]["ù{î—í#œD\031iÓ"]
p=220
elseif p==220 then
r[8]=r[6][31]
p=221
elseif p==221 then
r[16][1]=r[0]
p=222
elseif p==222 then
r[17][10]=r[255]
p=223
elseif p==223 then
r[18]=e[1]
p=224
elseif p==224 then
local x=z(r[16](q(r,17,251)))
for i=1,x.n do r[16+i-1]=x[i] end
top=16+x.n-1
p=225
elseif p==225 then
local x=z(r[20](r[21],r[22],r[23],r[24],r[25],r[26],r[27],r[28],r[29],r[30],r[31],r[32],r[33],r[34],r[35],r[36],r[37],r[38],r[39],r[40],r[41],r[42],r[43]))
for i=1,x.n do r[20+i-1]=x[i] end
top=20+x.n-1
p=226
elseif p==226 then
p=1
elseif p==227 then
r[0]=3
p=228
elseif p==228 then
r[0]=10
p=229
elseif p==229 then
r[0]="ve’n\023\rz"
p=230
elseif p==230 then
r[0]="´Úóç"
p=231
elseif p==231 then
r[0]="sub"
p=232
elseif p==232 then
r[0]="‘\006±Y"
p=233
elseif p==233 then
r[0]=" 5\011Üø\"lÊBmß¹,ÐXÉ\014”"
p=234
elseif p==234 then
r[20]=r[2][r[1]]
p=235
elseif p==235 then
r[19][r[0]]=r[0]
p=236
elseif p==236 then
r[16]=r[224]+r[255]
p=237
elseif p==237 then
r[14]=r[247][r[31]]
p=238
elseif p==238 then
p=248
elseif p==239 then
r[16]["‘\006±Y"]=r[0]
p=240
elseif p==240 then
r[17]=e["Your platform is unable to execute this script."]
p=241
elseif p==241 then
r[16]=r[2]["mVhdXUiDtBfsciSoi"]
p=242
elseif p==242 then
r[16]="tXvbuoHmlHHc"
p=243
elseif p==243 then
r[16]()
p=244
elseif p==244 then
r[0]["mVhdXUiDtBfsciSoi"]=r[255]
p=245
elseif p==245 then
r[16]=e[31]
p=246
elseif p==246 then
r[18]=r[4];r[17]=r[4][r[255]]
p=247
elseif p==247 then
r[17]()
p=248
elseif p==248 then
r[16]=u[12]
p=249
elseif p==249 then
r[7][18]=31
p=250
elseif p==250 then
r[16]=e[1]
p=251
elseif p==251 then
r[17]=10
p=252
elseif p==252 then
local x=z(r[18](q(r,19,89)))
for i=1,x.n do r[18+i-1]=x[i] end
top=18+x.n-1
p=253
elseif p==253 then
p=268
elseif p==254 then
r[20][10]=r[19]
p=255
elseif p==255 then
r[20],r[21],r[22],r[23],r[24],r[25],r[26],r[27],r[28],r[29],r[30],r[31],r[32],r[33],r[34],r[35],r[36],r[37],r[38]=r[20]()
p=256
elseif p==256 then
r[21]=r[266];r[20]=r[266]["‘\006±Y"]
p=257
elseif p==257 then
r[0]={}
p=258
elseif p==258 then
r[20]["‘\006±Y"]=r[255]
p=259
elseif p==259 then
r[21][" 5\011Üø\"lÊBmß¹,ÐXÉ\014”"]=r[255]
p=260
elseif p==260 then
r[20]["ù{î—í#œD\031iÓ"]="mVhdXUiDtBfsciSoi"
p=261
elseif p==261 then
r[20]="tXvbuoHmlHHc"
p=262
elseif p==262 then
r[20]="mVhdXUiDtBfsciSoi"
p=263
elseif p==263 then
local x=z(r[0](r[1]))
for i=1,x.n do r[0+i-1]=x[i] end
top=0+x.n-1
p=264
elseif p==264 then
r[20][12]=r[0]
p=265
elseif p==265 then
r[21]=e["mVhdXUiDtBfsciSoi"]
p=266
elseif p==266 then
r[21]=r[1]["mVhdXUiDtBfsciSoi"]
p=267
elseif p==267 then
r[16]=11
p=268
elseif p==268 then
r[16]=r[5]["ù{î—í#œD\031iÓ"]
p=269
elseif p==269 then
r[0]=r[6][r[255]]
p=270
elseif p==270 then
r[1]=r[10];r[0]=r[10][r[255]]
p=271
elseif p==271 then
r[17]="table"
p=272
elseif p==272 then
local x=z(r[18](r[19],r[20],r[21],r[22],r[23],r[24],r[25],r[26],r[27],r[28]))
for i=1,x.n do r[18+i-1]=x[i] end
top=18+x.n-1
p=273
elseif p==273 then
local x=z(r[19]())
for i=1,x.n do r[19+i-1]=x[i] end
top=19+x.n-1
p=274
elseif p==274 then
r[21]=r[36];r[20]=r[36][r[255]]
p=275
elseif p==275 then
r[21]=11
p=276
elseif p==276 then
local x=z(r[22](r[23],r[24],r[25],r[26],r[27],r[28],r[29],r[30],r[31],r[32],r[33],r[34]))
for i=1,x.n do r[22+i-1]=x[i] end
top=22+x.n-1
p=277
elseif p==277 then
r[24]=r[30];r[23]=r[30][r[255]]
p=278
elseif p==278 then
r[24]=35
p=279
elseif p==279 then
r[19]=r[19](r[20],r[21],r[22],r[23],r[24])
p=280
elseif p==280 then
r[20]="type"
p=281
elseif p==281 then
r[21]=";,2"
p=282
elseif p==282 then
local x=z(r[22]())
for i=1,x.n do r[22+i-1]=x[i] end
top=22+x.n-1
p=283
elseif p==283 then
r[23][6]=r[0]
p=284
elseif p==284 then
r[24]=e["ve’n\023\rz"]
p=285
elseif p==285 then
r[25]=r[16][r[255]]
p=286
elseif p==286 then
r[20]=6
p=287
elseif p==287 then
r[17]=e[12]
p=288
elseif p==288 then
r[19]=r[72];r[18]=r[72][r[255]]
p=289
elseif p==289 then
r[19]=7
p=290
elseif p==290 then
local x=z(r[20](r[21],r[22],r[23],r[24],r[25],r[26],r[27],r[28],r[29],r[30],r[31],r[32],r[33],r[34],r[35],r[36],r[37],r[38],r[39],r[40],r[41],r[42],r[43],r[44],r[45],r[46],r[47],r[48],r[49],r[50],r[51],r[52],r[53],r[54],r[55],r[56],r[57],r[58],r[59],r[60],r[61],r[62],r[63],r[64],r[65],r[66],r[67],r[68],r[69],r[70],r[71],r[72]))
for i=1,x.n do r[20+i-1]=x[i] end
top=20+x.n-1
p=291
elseif p==291 then
r[18]=r[310][r[255]]
p=292
elseif p==292 then
r[22]=r[72][r[255]]
p=293
elseif p==293 then
r[24]=r[11];r[23]=r[11][r[255]]
p=294
elseif p==294 then
r[24]=e[1]
p=295
elseif p==295 then
r[22]=r[309][r[255]]
p=296
elseif p==296 then
r[26]=31
p=297
elseif p==297 then
r[27]=10
p=298
elseif p==298 then
r[28],r[29],r[30],r[31],r[32],r[33],r[34],r[35],r[36],r[37],r[38],r[39],r[40],r[41],r[42],r[43],r[44],r[45],r[46],r[47]=r[28]()
p=299
elseif p==299 then
r[26]["print"]=r[2]
p=300
elseif p==300 then
r[26]["getfenv"]="mVhdXUiDtBfsciSoi"
p=301
elseif p==301 then
p=303
elseif p==302 then
p=309
elseif p==303 then
r[26]["‘\006±Y"]=r[0]
p=304
elseif p==304 then
r[27]=e[" 5\011Üø\"lÊBmß¹,ÐXÉ\014”"]
p=305
elseif p==305 then
r[26]=r[2]["mVhdXUiDtBfsciSoi"]
p=306
elseif p==306 then
r[26]="tXvbuoHmlHHc"
p=307
elseif p==307 then
r[26]()
p=308
elseif p==308 then
r[0]["mVhdXUiDtBfsciSoi"]=r[255]
p=309
elseif p==309 then
r[22]=e["getfenv"]
p=310
elseif p==310 then
r[18]=u[292]
p=311
elseif p==311 then
r[18]=u[46]
p=312
elseif p==312 then
r[18]=u[315]
p=313
elseif p==313 then
local x=z(r[0](q(r,1,313)))
for i=1,x.n do r[0+i-1]=x[i] end
top=0+x.n-1
p=314
elseif p==314 then
r[0]["getfenv"]=r[0]
p=315
elseif p==315 then
r[18]=u[60]
p=316
elseif p==316 then
r[19]=u[19]
p=317
elseif p==317 then
r[20]=r[18][r[255]]
p=318
elseif p==318 then
if not r[21] then p=319 else p=320 end
elseif p==319 then
r[22]["à=§»"]=r[0]
p=320
elseif p==320 then
r[23][13]=r[0]
p=321
elseif p==321 then
r[24]=e[5]
p=322
elseif p==322 then
r[25]=r[74][r[255]]
p=323
elseif p==323 then
r[26]=15
p=324
elseif p==324 then
r[21]=r[21](r[22],r[23],r[24],r[25],r[26],r[27],r[28],r[29],r[30],r[31],r[32],r[33],r[34],r[35],r[36],r[37],r[38],r[39],r[40],r[41],r[42],r[43],r[44],r[45],r[46])
p=325
elseif p==325 then
r[20]["ù{î—í#œD\031iÓ"]="ù{î—í#œD\031iÓ"
p=326
elseif p==326 then
r[20]=r[20]()
p=327
elseif p==327 then
r[21][218]=r[0]
p=328
elseif p==328 then
r[22]=e["mVhdXUiDtBfsciSoi"]
p=329
elseif p==329 then
r[20]=r[22][r[255]]
p=330
elseif p==330 then
r[19]=r[0]["ù{î—í#œD\031iÓ"]
p=331
elseif p==331 then
r[20]["table"]=r[0]
p=332
elseif p==332 then
r[19]=12
p=333
elseif p==333 then
r[19][r[255]]=r[0]
p=334
elseif p==334 then
r[0]=r[0][r[0]]
p=335
elseif p==335 then
r[0]=u[2]
p=336
else break end
end
end
return f[0]({},...)
