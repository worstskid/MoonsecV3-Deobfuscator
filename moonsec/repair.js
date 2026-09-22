const fs=require("fs")
const cp=require("child_process")

function run(file,luac){
  for(let n=0;n<256;n++){
    const r=cp.spawnSync(luac,["-p",file],{encoding:"utf8",windowsHide:true})
    if(r.status===0)return
    const e=String(r.stderr||r.stdout||"")
    const m=e.match(/:(\d+):\s*'<eof>' expected near 'end'/)
    const q=e.match(/:(\d+):\s*'<eof>' expected near /)
    const c=e.match(/'([)}\]])' expected[\s\S]*near '<eof>'/)
    if(c){fs.appendFileSync(file,"\n"+c[1]);continue}
    const z=/'end' expected[\s\S]*near '<eof>'/.test(e)
    if(z){fs.appendFileSync(file,"\nend");continue}
    const y=e.match(/:(\d+):\s*'end' expected[\s\S]*near '(?:else|elseif)'/)
    if(y){
      const a=fs.readFileSync(file,"utf8").split(/\r?\n/)
      const i=Number(y[1])-1
      const d=(a[i]?.match(/^\s*/)||[""])[0]
      a.splice(i,0,d+"end")
      fs.writeFileSync(file,a.join("\n"))
      continue
    }
    if(!m&&!q){
      const v=e.match(/:(\d+):/)
      if(!v)throw Error(e.trim()||"Lua syntax validation failed")
      const a=fs.readFileSync(file,"utf8").split(/\r?\n/)
      const i=Number(v[1])-1
      if(!a[i])throw Error(e.trim())
      const d=(a[i].match(/^\s*/)||[""])[0]
      if(/^\s*if\b/.test(a[i]))a[i]=d+"if false then"
      else if(/^\s*elseif\b/.test(a[i]))a[i]=d+"elseif false then"
      else if(/^\s*(?:for|while)\b/.test(a[i]))a[i]=d+"if false then"
      else if(/^\s*function\b/.test(a[i]))a[i]=d+"local function recovered"+n+"(...)"
      else if(/^\s*(?:else|end|until)\b/.test(a[i]))a.splice(i,1)
      else a[i]=d+"--[[ couldn't recover ]]"
      fs.writeFileSync(file,a.join("\n"))
      continue
    }
    const a=fs.readFileSync(file,"utf8").split(/\r?\n/)
    const i=Number((m||q)[1])-1
    if(m&&a[i]&&a[i].trim()==="end")a.splice(i,1)
    else if(q){
      let d=(a[i].match(/^\s*/)||[""])[0].length,j=i-1
      while(j>=0){
        let z=(a[j].match(/^\s*/)||[""])[0].length
        if(z===d&&/^return\b/.test(a[j].trim()))break
        if(z<d)j=-1
        else j--
      }
      if(j<0)throw Error(e.trim())
      a[j]=a[j].replace(/^(\s*)(return\b.*)$/,"$1do $2 end")
    }else throw Error(e.trim())
    fs.writeFileSync(file,a.join("\n"))
  }
  throw Error("Lua syntax repair limit reached")
}

module.exports={run}
