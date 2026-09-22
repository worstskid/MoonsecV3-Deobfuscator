const id='[A-Za-z_][A-Za-z0-9_]*'
const mark='--[=[ deobfuscated by sergei.dev @ .gg/svgmV95Apm ]=]--'
const head=/^(?:(?:--\[=\[ deobfuscated by sergei\.dev @ \.gg\/svgmV95Apm \]=\]--|-- Disassembled with MoonSec V3 deobfuscator by #tupsutumppu)\s*)+/

function n(s){
  return s.replace(/_G\["([A-Za-z_][A-Za-z0-9_]*)"\]/g,'$1').replace(new RegExp(`(${id}(?:\\.${id})*)\\["(${id})"\\]`,'g'),'$1.$2')
}

function nm(s,u){
  let v=String(s).toLowerCase().replace(/[^a-z0-9]/g,'')
  if(!/^[a-z]/.test(v))v='service'
  let x=v,i=2
  while(u.has(x))x=v+i++
  u.add(x)
  return x
}

function rep(a,o,at,x,ind){
  let d=ind.length
  let sh=[]
  for(let i=o;i<a.length;i++){
    let l=a[i],z=l.match(/^\s*/)[0].length
    while(sh.length&&z<=sh[sh.length-1])sh.pop()
    let fn=l.match(/^\s*(?:local\s+)?function\s+[^()]*(?:\(([^)]*)\))/)
    if(fn&&z<=d)break
    if(fn&&new RegExp(`(?:^|,\\s*)${at}(?:\\s*,|$)`).test(fn[1])){
      sh.push(z)
      continue
    }
    if(new RegExp(`^\\s*local\\s+${at}\\b`).test(l)){
      sh.push(Math.max(-1,z-1))
      continue
    }
    if(sh.length)continue
    if(z<=d&&new RegExp(`^\\s*(?:local\\s+)?${at}\\s*=`).test(l)){
      a[i]=l.replace(new RegExp(`(=\\s*)${at}\\b`),'$1'+x)
      break
    }
    a[i]=l.replace(new RegExp(`\\b${at}\\b`,'g'),x)
  }
}

function svc(a){
  let u=new Set()
  for(let i=0;i<a.length-3;i++){
    let x=a[i].match(/^(\s*)(?:local\s+)?(var\d+)\s*=\s*game\s*$/)
    if(!x)continue
    let y=a[i+1].match(/^\s*(?:local\s+)?(var\d+)\s*=\s*(var\d+)\s*;\s*(var\d+)\s*=\s*\3\.GetService\s*$/)
    let z=a[i+2].match(/^\s*(?:local\s+)?(var\d+)\s*=\s*"([^"]+)"\s*$/)
    let q=a[i+3].match(/^\s*(var\d+)\s*=\s*\1\((var\d+),\s*(var\d+)\)\s*$/)
    if(!y||!z||!q||y[2]!==x[2]||y[3]!==x[2]||q[1]!==x[2]||q[2]!==y[1]||q[3]!==z[1])continue
    let v=nm(z[2],u)
    a.splice(i,4,`${x[1]}local ${v} = game:GetService("${z[2]}")`)
    rep(a,i+1,x[2],v,x[1])
  }
  return a
}

function direct(a){
  for(let pass=0;pass<4;pass++){
    let hit=false
    for(let i=0;i<a.length-1;i++){
      let x=a[i].match(/^(\s*)(local\s+)?(var\d+)\s*=\s*([A-Za-z_][A-Za-z0-9_.:]*)\s*$/)
      if(!x)continue
      let y=a[i+1].match(new RegExp(`^\\s*${x[3]}\\s*=\\s*${x[3]}\\((.*)\\)\\s*$`))
      if(!y)continue
      a.splice(i,2,`${x[1]}${x[2]||''}${x[3]} = ${x[4]}(${y[1]})`)
      hit=true
    }
    if(!hit)break
  }
  for(let pass=0;pass<12;pass++){
    let hit=false
    for(let i=0;i<a.length-1;i++){
      let x=a[i].match(/^(\s*)(local\s+)?(var\d+)\s*=\s*([A-Za-z_][A-Za-z0-9_.:]*)\s*$/)
      if(!x)continue
      let m=new Map(),j=i+1
      for(;j<a.length&&j<i+20;j++){
        let z=a[j].match(/^\s*(?:local\s+)?(var\d+)\s*=\s*(nil|true|false|-?(?:\d+(?:\.\d*)?|\.\d+)(?:E[+-]?\d+)?|"(?:[^"\\]|\\.)*")\s*$/i)
        if(!z)break
        m.set(z[1],z[2])
      }
      let q=a[j]&&a[j].match(new RegExp(`^\\s*${x[3]}\\s*=\\s*${x[3]}\\((.*)\\)\\s*$`))
      if(!q)continue
      let p=q[1].split(',').map(v=>m.get(v.trim())||v.trim()).join(', ')
      a.splice(i,j-i+1,`${x[1]}${x[2]||''}${x[3]} = ${x[4]}(${p})`)
      hit=true
    }
    if(!hit)break
  }
  for(let pass=0;pass<12;pass++){
    let hit=false
    for(let i=0;i<a.length-1;i++){
      let x=a[i].match(/^(\s*)(?:local\s+)?(var\d+)\s*=\s*([A-Za-z_][A-Za-z0-9_.:]*)\s*$/)
      if(!x)continue
      let m=new Map(),j=i+1
      for(;j<a.length&&j<i+20;j++){
        let z=a[j].match(/^\s*(?:local\s+)?(var\d+)\s*=\s*(nil|true|false|-?(?:\d+(?:\.\d*)?|\.\d+)(?:E[+-]?\d+)?|"(?:[^"\\]|\\.)*")\s*$/i)
        if(!z)break
        m.set(z[1],z[2])
      }
      let q=a[j]&&a[j].match(new RegExp(`^(\\s*)(.+?)\\s*=\\s*${x[2]}\\((.*)\\)\\s*$`))
      if(!q)continue
      let p=q[3].split(',').map(v=>m.get(v.trim())||v.trim()).join(', ')
      a.splice(i,j-i+1,`${q[1]}${q[2].trim()} = ${x[3]}(${p})`)
      hit=true
    }
    if(!hit)break
  }
  return a
}

function chain(a){
  for(let pass=0;pass<8;pass++){
    let hit=false
    for(let i=0;i<a.length-1;i++){
      let x=a[i].match(/^(\s*)(local\s+)?(var\d+)\s*=\s*([A-Za-z_][A-Za-z0-9_.:]*)\s*$/)
      if(!x)continue
      let y=a[i+1].match(new RegExp(`^\\s*${x[3]}\\s*=\\s*${x[3]}([.:][A-Za-z_][A-Za-z0-9_]*)\\s*$`))
      if(!y)continue
      a.splice(i,2,`${x[1]}${x[2]||''}${x[3]} = ${x[4]}${y[1]}`)
      hit=true
    }
    if(!hit)break
  }
  for(let i=0;i<a.length-1;i++){
    let x=a[i].match(/^(\s*)(?:local\s+)?(var\d+)\s*=\s*(.+)$/)
    if(!x||/\bfunction\b/.test(x[3]))continue
    let y=a[i+1].match(new RegExp(`^(\\s*)([A-Za-z_][A-Za-z0-9_.]*)\\s*=\\s*${x[2]}\\s*$`))
    if(y){a.splice(i,2,`${y[1]}${y[2]} = ${x[3]}`);i--}
  }
  return a
}

function locals(a){
  let d=new Set()
  for(let i=0;i<a.length;i++){
    let x=a[i].match(/^\s*local\s+((?:var\d+\s*,\s*)*var\d+)\s*$/)
    if(!x)continue
    for(let n of x[1].match(/var\d+/g)||[])d.add(n)
    a.splice(i--,1)
  }
  let seen=new Set()
  for(let i=0;i<a.length;i++){
    let x=a[i].match(/^(\s*)(var\d+)\s*=/)
    if(!x||!d.has(x[2])||seen.has(x[2]))continue
    seen.add(x[2])
    a[i]=a[i].replace(/^(\s*)/,"$1local ")
  }
  return a
}

function smart(a){
  let u=new Set((a.join('\n').match(/\b(?!var\d+\b)[a-z][A-Za-z0-9_]*\b/g)||[]))
  for(let i=0;i<a.length;i++){
    let x=a[i].match(/^(\s*)(?:local\s+)?(var\d+)\s*=\s*Instance\.new\("([A-Za-z0-9_]+)"(?:,\s*([^)]*))?\)\s*$/)
    if(!x)continue
    let h=x[3].toLowerCase().replace(/^ui/,'')||'object'
    for(let j=i+1;j<Math.min(a.length,i+20);j++){
      let z=a[j].match(new RegExp(`^\\s*${x[2]}\\.(?:Name|Text)\\s*=\\s*"([^"]+)"`))
      if(z){h=z[1].toLowerCase().replace(/[^a-z0-9]/g,'')+(x[3]==='TextButton'?'button':'');break}
      if(new RegExp(`^\\s*${x[2]}\\s*=`).test(a[j]))break
    }
    let v=nm(h,u)
    a[i]=`${x[1]}local ${v} = Instance.new("${x[3]}"${x[4]?`, ${x[4]}`:''})`
    rep(a,i+1,x[2],v,x[1])
  }
  for(let i=0;i<a.length;i++){
    let x=a[i].match(/^(\s*)(?:local\s+)?(var\d+)\s*=\s*(game(?:\.[A-Za-z_][A-Za-z0-9_]*)*\.LocalPlayer)\s*$/)
    if(!x)continue
    let v=nm('player',u)
    a[i]=`${x[1]}local ${v} = ${x[3]}`
    rep(a,i+1,x[2],v,x[1])
  }
  for(let i=0;i<a.length-1;i++){
    let x=a[i].match(/^(\s*)(?:local\s+)?(var\d+)\s*=\s*(Color3\.(?:fromRGB|new)\([^)]*\)|UDim2?\.new\([^)]*\)|Vector[23]\.new\([^)]*\)|Enum(?:\.[A-Za-z_][A-Za-z0-9_]*)+)\s*$/)
    if(!x)continue
    let y=a[i+1].match(new RegExp(`^(\\s*)([^=]+?)\\s*=\\s*${x[2]}\\s*$`))
    if(y){a.splice(i,2,`${y[1]}${y[2].trim()} = ${x[3]}`);i--}
  }
  return a
}

function ctor(a){
  for(let i=0;i<a.length-3;i++){
    let x=a[i].match(/^(\s*)(?:local\s+)?(var\d+)\s*=\s*([A-Za-z_][A-Za-z0-9_.]*)$/)
    if(!x)continue
    let y=a[i+1].match(new RegExp(`^\\s*${x[2]}\\s*=\\s*${x[2]}\\.new\\s*$`))
    if(!y)continue
    let m=new Map(),j=i+2
    for(;j<a.length&&j<i+40;j++){
      let z=a[j].match(/^\s*(?:local\s+)?(var\d+)\s*=\s*(nil|true|false|-?(?:\d+(?:\.\d*)?|\.\d+)(?:E[+-]?\d+)?|"(?:[^"\\]|\\.)*")\s*$/i)
      if(!z)break
      m.set(z[1],z[2])
    }
    let q=a[j]&&a[j].match(new RegExp(`^\\s*${x[2]}\\s*=\\s*${x[2]}\\(([^)]*)\\)\\s*$`))
    let z=a[j+1]&&a[j+1].match(new RegExp(`^(\\s*)(.+)\\s*=\\s*${x[2]}\\s*$`))
    if(!q||!z)continue
    let p=q[1].split(',').map(v=>m.get(v.trim())||v.trim()).join(', ')
    a.splice(i,j-i+2,`${z[1]}${z[2].trim()} = ${x[3]}.new(${p})`)
  }
  return a
}

function calls(a){
  for(let i=0;i<a.length-2;i++){
    let x=a[i].match(/^(\s*)(local\s+)?(var\d+)\s*=\s*(.+?)\s*$/)
    let y=a[i+1]&&a[i+1].match(/^\s*(?:local\s+)?(var\d+)\s*=\s*(var\d+)\s*;\s*(var\d+)\s*=\s*\3\.([A-Za-z_][A-Za-z0-9_]*)\s*$/)
    if(!x||!y||/^(?:["']|[-.\d]|nil\b|true\b|false\b|\{)/.test(x[4])||y[2]!==x[3]||y[3]!==x[3])continue
    let m=new Map(),j=i+2
    for(;j<a.length&&j<i+30;j++){
      let z=a[j].match(/^\s*(?:local\s+)?(var\d+)\s*=\s*(nil|true|false|-?(?:\d+(?:\.\d*)?|\.\d+)(?:E[+-]?\d+)?|"(?:[^"\\]|\\.)*")\s*$/i)
      if(!z)break
      m.set(z[1],z[2])
    }
    let q=a[j]&&a[j].match(new RegExp(`^\\s*(?:${x[3]}\\s*=\\s*)?${x[3]}\\(${y[1]}(?:,\\s*([^)]*))?\\)\\s*$`))
    if(!q)continue
    let p=(q[1]||'').split(',').filter(Boolean).map(v=>m.get(v.trim())||v.trim()).join(', ')
    a.splice(i,j-i+1,`${x[1]}${x[2]||''}${x[3]} = ${x[4]}:${y[4]}(${p})`)
  }
  for(let i=0;i<a.length-1;i++){
    let x=a[i].match(/^(\s*)(?:local\s+)?(var\d+)\s*=\s*([A-Za-z_][A-Za-z0-9_.]*)\s*;\s*(var\d+)\s*=\s*\3\.([A-Za-z_][A-Za-z0-9_]*)\s*$/)
    if(!x)continue
    let m=new Map(),j=i+1
    for(;j<a.length&&j<i+20;j++){
      let z=a[j].match(/^\s*(?:local\s+)?(var\d+)\s*=\s*(nil|true|false|-?(?:\d+(?:\.\d*)?|\.\d+)(?:E[+-]?\d+)?|"(?:[^"\\]|\\.)*")\s*$/i)
      if(!z)break
      m.set(z[1],z[2])
    }
    let q=a[j]&&a[j].match(new RegExp(`^\\s*(?:${x[4]}\\s*=\\s*)?${x[4]}\\(${x[2]}(?:,\\s*([^)]*))?\\)\\s*$`))
    if(!q)continue
    let p=(q[1]||'').split(',').filter(Boolean).map(v=>m.get(v.trim())||v.trim()).join(', ')
    a.splice(i,j-i+1,`${x[1]}${x[3]}:${x[5]}(${p})`)
  }
  for(let i=0;i<a.length-4;i++){
    let x=a[i].match(/^(\s*)(?:local\s+)?(var\d+)\s*=\s*loadstring\s*$/)
    let y=a[i+1]&&a[i+1].match(/^\s*(?:local\s+)?(var\d+)\s*=\s*(game:HttpGet\(.+\))\s*$/)
    let z=a[i+2]&&a[i+2].match(new RegExp(`^\\s*${x?x[2]:'x'}\\s*=\\s*${x?x[2]:'x'}\\(${y?y[1]:'y'}\\)\\s*$`))
    let q=a[i+3]&&a[i+3].match(new RegExp(`^\\s*${x?x[2]:'x'}\\s*=\\s*${x?x[2]:'x'}\\(\\)\\s*$`))
    let w=a[i+4]&&a[i+4].match(new RegExp(`^(\\s*)(?:local\\s+)?(var\\d+)\\s*=\\s*${x?x[2]:'x'}\\s*$`))
    if(!x||!y||!z||!q||!w)continue
    a.splice(i,5,`${w[1]}${w[2]} = loadstring(${y[2]})()`)
  }
  for(let i=0;i<a.length-3;i++){
    let x=a[i].match(/^(\s*)(local\s+)?(var\d+)\s*=\s*loadstring\s*$/)
    let y=a[i+1]&&a[i+1].match(/^\s*(?:local\s+)?(var\d+)\s*=\s*(game:HttpGet\(.+\))\s*$/)
    let z=a[i+2]&&a[i+2].match(new RegExp(`^\\s*${x?x[3]:'x'}\\s*=\\s*${x?x[3]:'x'}\\(${y?y[1]:'y'}\\)\\s*$`))
    let q=a[i+3]&&a[i+3].match(new RegExp(`^\\s*(${x?x[3]:'x'}\\s*=\\s*)?${x?x[3]:'x'}\\(\\)\\s*$`))
    if(!x||!y||!z||!q)continue
    let v=q[1]?`${x[2]||''}${x[3]} = `:''
    a.splice(i,4,`${x[1]}${v}loadstring(${y[2]})()`)
  }
  return a
}

function tables(a){
  for(let i=0;i<a.length;i++){
    let x=a[i].match(/^(\s*)(var\d+)\s*=\s*\{\}\s*$/)
    if(!x)continue
    let vals=new Map(),j=i+1,hit=null
    for(;j<a.length&&j<i+40;j++){
      let q=a[j].match(new RegExp('^\\s*'+x[2]+'\\s*=\\s*\\{([^{}]*)\\}\\s*$'))
      if(q){let ns=q[1].split(',').map(v=>v.trim()).filter(Boolean);if(ns.length&&ns.every(n=>vals.has(n)))hit={j,ns};break}
      let z=a[j].match(/^\s*(?:local\s+)?(var\d+)\s*=\s*(nil|true|false|-?(?:\d+(?:\.\d*)?|\.\d+)(?:E[+-]?\d+)?|"(?:[^"\\]|\\.)*")\s*$/i)
      if(!z)break
      vals.set(z[1],z[2])
    }
    if(hit){
      a.splice(i,hit.j-i+1,`${x[1]}${x[2]} = {${hit.ns.map(n=>vals.get(n)).join(', ')}}`)
      i--
    }
  }
  for(let i=0;i<a.length;i++){
    let x=a[i].match(/^(\s*)(var\d+)\s*=\s*\{([^{}]*)\}\s*$/)
    if(!x)continue
    let ns=x[3].split(',').map(v=>v.trim()).filter(v=>/^var\d+$/.test(v))
    if(!ns.length)continue
    let vals=new Map(),start=i
    for(let j=i-1;j>=0&&i-j<=ns.length+3;j--){
      let z=a[j].match(/^\s*(?:local\s+)?(var\d+)\s*=\s*(nil|true|false|-?(?:\d+(?:\.\d*)?|\.\d+)(?:E[+-]?\d+)?|"(?:[^"\\]|\\.)*")\s*$/i)
      if(!z)break
      vals.set(z[1],z[2])
      if(ns.every(n=>vals.has(n)))start=j
    }
    if(!ns.every(n=>vals.has(n)))continue
    let p=ns.map(n=>vals.get(n)).join(', ')
    a[i]=`${x[1]}${x[2]} = {${p}}`
    for(let j=i-1;j>=start;j--){
      let z=a[j].match(/^\s*(?:local\s+)?(var\d+)\s*=/)
      if(z&&ns.includes(z[1])){
        let pre=a.slice(0,j).join('\n'),post=a.slice(i+1).join('\n')
        let uses=(pre+'\n'+post).match(new RegExp('\\b'+z[1]+'\\b','g'))||[]
        if(!uses.length)a.splice(j,1),i--
      }
    }
  }
  return a
}

function maps(a){
 for(let i=0;i<a.length-1;i++){
 let x=a[i].match(/^(\s*)(var\d+)\s*=\s*(\{[^{}]*\})\s*$/)
  if(x){
   let q=a[i+1].match(new RegExp('^(\\s*)(.+?)\\s*=\\s*'+x[2]+'\\s*$'))
   if(q){a.splice(i,2,`${q[1]}${q[2].trim()} = ${x[3]}`);i--;continue}
  }
 }
 for(let i=0;i<a.length;i++){
  let hit=a[i].match(/^(\s*)([^=]+?)\s*=\s*\{(var\d+(?:\s*,\s*var\d+)*)\}\s*$/)
  if(!hit)continue
  let ns=hit[3].split(/\s*,\s*/), vals=new Map(),start=i
  for(let j=i-1;j>=0&&i-j<=ns.length+3;j--){
   let z=a[j].match(/^\s*(?:local\s+)?(var\d+)\s*=\s*(nil|true|false|-?(?:\d+(?:\.\d*)?|\.\d+)(?:E[+-]?\d+)?|"(?:[^"\\]|\\.)*")\s*$/i)
   if(!z)break
   vals.set(z[1],z[2]);start=j
  }
  if(!ns.every(n=>vals.has(n)))continue
  a[i]=`${hit[1]}${hit[2].trim()} = {${ns.map(n=>vals.get(n)).join(', ')}}`
  for(let j=i-1;j>=start;j--)if(/^\s*(?:local\s+)?var\d+\s*=/.test(a[j]))a.splice(j,1),i--
 }
 return a
}

function refs(a){
  for(let i=0;i<a.length;i++){
    let x=a[i].match(/^(\s*)((?:local\s+)?var\d+)\s*=\s*nil\s*--\[\[ couldn't recover \]\]\s*$/)
    if(!x)continue
    let fn=null
    for(let j=i-1;j>=0;j--){
      let y=a[j].match(new RegExp(`^${x[1]}(?:local\\s+)?function\\s+([A-Za-z_][A-Za-z0-9_]*)\\b`))
      if(y){fn=y[1];break}
      if(a[j].trim()&&a[j].match(/^\s*/)[0].length<x[1].length)break
    }
    if(fn)a[i]=`${x[1]}${x[2]} = ${fn}`
  }
  for(let i=0;i<a.length-1;i++){
    let x=a[i].match(/^(\s*)((?:local\s+)?var\d+)\s*=\s*([A-Za-z_][A-Za-z0-9_]*)\s*$/)
    let y=a[i+1]&&a[i+1].match(/^(\s*)([A-Za-z_][A-Za-z0-9_.]*)\.([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(var\d+)\s*$/)
    if(x&&y&&x[2].replace(/^local\s+/,'')===y[4]&&x[3]===y[3])a.splice(i,2,`${y[1]}${y[2]}.${y[3]} = ${x[3]}`)
  }
  for(let i=1;i<a.length;i++){
    let x=a[i-1].match(/^\s*(?:local\s+)?(var\d+)\s*=\s*loadstring\(game:HttpGet\(.+\)\)\(\)\s*$/)
    if(x&&new RegExp(`^\\s*${x[1]}\\s*=\\s*["']loadstring["']\\s*$`).test(a[i])){a.splice(i,1);i--}
  }
  return a
}

function fns(a){
  let u=new Set()
  for(let i=0;i<a.length;i++){
    let x=a[i].match(/^(\s*)(local\s+)?function\s+(CRoot_\d+|fn\d+(?:_\d+)*)\b/)
    if(!x)continue
    let v=null
    for(let j=i+1;j<Math.min(a.length,i+30);j++){
      if(a[j].match(/^\s*/)[0].length<=x[1].length&&a[j].trim()==='end')break
      let y=a[j].match(/game:HttpGet\("[^"]*\/([^/"?]+?)(?:\.lua)?(?:\?[^"/]*)?"\)/i)
      if(y){v=nm('load'+y[1],u);break}
    }
    if(!v)continue
    let old=x[3]
    a[i]=a[i].replace(new RegExp(`\\b${old}\\b`),v)
    for(let j=i+1;j<Math.min(a.length,i+50);j++)a[j]=a[j].replace(new RegExp(`\\b${old}\\b`,'g'),v)
  }
  return a
}

function cb(a){
  for(let i=0;i<a.length;i++){
    let x=a[i].match(/^(\s*)(?:local\s+)?(var\d+)\s*=\s*(pcall|spawn)\s*$/)
    if(!x)continue
    for(let j=i+1;j<Math.min(a.length,i+50);j++){
      let y=a[j].match(/^\s*(?:local\s+)?(var\d+)\s*=\s*([A-Za-z_][A-Za-z0-9_]*)\s*$/)
      if(!y)continue
      let k=j+1
      while(k<Math.min(a.length,j+5)&&!new RegExp(`^\\s*${x[2]}\\(${y[1]}\\)\\s*$`).test(a[k]))k++
      if(k>=Math.min(a.length,j+5))continue
      a[k]=`${x[1]}${x[3]}(${y[2]})`
      for(let z=k-1;z>j;z--)if(/^\s*(?:local\s+)?var\d+\s*=\s*var\d+\s*$/.test(a[z])){a.splice(z,1);k--}
      a.splice(j,1)
      a.splice(i,1)
      i--
      break
    }
  }
  for(let i=0;i<a.length-1;i++){
    let x=a[i].match(/^(\s*)local\s+var\d+\s*=\s*(loadstring\(game:HttpGet\(.+\)\)\(\))\s*$/)
    if(x&&a[i+1].trim()==='return')a[i]=x[1]+x[2]
  }
  return a
}

function names(a){
  let u=new Set(),seen=new Set()
  for(let i=0;i<a.length;i++){
    let x=a[i].match(/^(\s*)(var\d+)\s*=\s*\{\s*-?\d+(?:\s*,\s*-?\d+)+\s*\}\s*$/)
    let y=a[i+1]&&a[i+1].match(/^\s*local\s+(\w+)\s*=\s*table\.find\s*$/)
    let z=a[i+2]&&a[i+2].match(new RegExp('^\\s*var\\d+\\s*=\\s*'+(x&&x[2]||'x')+'\\s*$'))
    if(x&&y&&z){let v=nm('values',u);a[i]=`${x[1]}local ${v} = ${x[0].slice(x[0].indexOf('=')+1).trim()}`;rep(a,i+1,x[2],v,x[1])}
  }
  for(let i=0;i<a.length;i++){
    let x=a[i].match(/^(\s*)(?:local\s+)?(var\d+)\s*=\s*(getexecutorname\(\)(?::sub\([^)]*\))?)\s*$/)
    if(!x)continue
    let v=nm('executor',u)
    a[i]=`${x[1]}local ${v} = ${x[3]}`
    rep(a,i+1,x[2],v,x[1])
  }
  let hint={EspDisabled:'esp',Enabled:'settings',Combat:'config',killAura:'combat',WalkSpeed:'character',ClickTP:'misc'}
  for(let i=0;i<a.length;i++){
    let x=a[i].match(/^(\s*)(?:local\s+)?(var\d+)\s*=\s*\{\}\s*$/)
    if(!x)continue
    let key=null,n=0
    for(let j=i+1;j<Math.min(a.length,i+30);j++){
      let z=a[j].match(new RegExp(`^${x[1]}${x[2]}\\.([A-Za-z_][A-Za-z0-9_]*)\\s*=`))
      if(z){key=key||z[1];n++;continue}
      if(a[j].trim()&&a[j].match(/^\s*/)[0].length<x[1].length)break
    }
    if(n<2||!hint[key])continue
    let v=nm(hint[key],u)
    a[i]=`${x[1]}local ${v} = {}`
    rep(a,i+1,x[2],v,x[1])
  }
  for(let i=0;i<a.length;i++){
    let l=a[i]
    let x=l.match(/^(\s*)(?:local\s+)?(var\d+)\s*=\s*([a-z][A-Za-z0-9_]*)\.([A-Za-z_][A-Za-z0-9_]*)\s*$/)
    if(x&&!seen.has(x[2])){
      let v=nm(x[4]==='LocalPlayer'?'player':x[4],u)
      a[i]=`${x[1]}local ${v} = ${x[3]}.${x[4]}`
      rep(a,i+1,x[2],v,x[1])
    }
    for(let y of l.matchAll(/\bvar\d+\b/g))seen.add(y[0])
  }
  for(let i=0;i<a.length;i++){
    let x=a[i].match(/^(\s*)local\s+(var\d+)\s*=\s*\{\}\s*$/)
    if(!x)continue
    let n=0,loc=0
    for(let j=i+1;j<Math.min(a.length,i+120);j++){
      if(new RegExp(`^${x[1]}${x[2]}(?:\\.|\\[)`).test(a[j])){
        n++
        if(/CFrame\.new\(/.test(a[j]))loc++
      }
    }
    if(n<2)continue
    let v=nm(loc>1?'locations':'data',u)
    a[i]=`${x[1]}local ${v} = {}`
    rep(a,i+1,x[2],v,x[1])
  }
  for(let i=0;i<a.length;i++){
    let x=a[i].match(/^(\s*)(var\d+)\s*=\s*\{\}\s*$/)
    if(!x)continue
    let n=0,keys=0
    for(let j=i+1;j<Math.min(a.length,i+140);j++){
      let z=a[j].match(new RegExp('^'+x[1]+x[2]+'\\["[^"\\n]+"\\]\\s*='))
      if(z){n++;keys++}
      else if(new RegExp('^'+x[1]+x[2]+'\\b').test(a[j]))n++
    }
    if(keys<4)continue
    let v=nm('map',u)
    a[i]=`${x[1]}local ${v} = {}`
    rep(a,i+1,x[2],v,x[1])
  }
  return a
}

function fix(a){
  let st=[]
  let out=[]
  for(let i=0;i<a.length;i++){
    let l=a[i]
    let t=l.trim()
    if(/^else(?:if\b.*then)?$/.test(t)){
      let z=st[st.length-1]
      if(!z||z.k!=='if'){
        if(a[i+1]&&a[i+1].trim()==='end')i++
        continue
      }
      if(z.alt){
        out.push(l.match(/^\s*/)[0]+'end')
        st.pop()
        if(/^elseif\b/.test(t)){
          l=l.replace(/^\s*elseif\b/,'if')
          st.push({k:'if',alt:false})
        }else{
          l=l.match(/^\s*/)[0]+'if true then'
          st.push({k:'if',alt:false})
        }
      }else if(t==='else')z.alt=true
    }else if(t==='end'||/^end[)}]/.test(t)){
      if(!st.length)continue
      st.pop()
    }else if(/^until\b/.test(t)){
      let k=st.map(x=>x.k).lastIndexOf('repeat')
      if(k>=0)st.length=k
    }else if(/^if\b.*then$/.test(t))st.push({k:'if',alt:false})
    else if(/^(?:local\s+)?function\b/.test(t)||/\bfunction\s*\([^)]*\)\s*$/.test(t))st.push({k:'function'})
    else if(/^(?:for|while)\b.*do$/.test(t)||t==='do')st.push({k:'block'})
    else if(t==='repeat')st.push({k:'repeat'})
    out.push(l)
  }
  while(st.length){out.push('end');st.pop()}
  for(let i=0;i<out.length;i++){
    let m=out[i].match(/^(\s*)(return\b.*)$/)
    if(!m)continue
    let c=code(out[i]),open=(c.match(/[({[]/g)||[]).length-(c.match(/[)}\]]/g)||[]).length
    if(open>0)continue
    let d=m[1].length,j=i+1
    while(j<out.length&&!out[j].trim())j++
    if(j<out.length&&out[j].match(/^\s*/)[0].length===d&&!/^(?:end|else|elseif|until)\b/.test(out[j].trim()))out[i]=`${m[1]}do ${m[2]} end`
  }
  return out
}

function code(s){
  let o='',i=0
  while(i<s.length){
    let c=s[i]
    if(c==='"'||c==="'"){
      let q=c
      o+=' '
      i++
      while(i<s.length){
        if(s[i]==='\\'){o+='  ';i+=2;continue}
        if(s[i]===q){o+=' ';i++;break}
        o+=s[i]==='\n'?'\n':' '
        i++
      }
      continue
    }
    if(c==='-'&&s[i+1]==='-'){
      let m=s.slice(i+2).match(/^\[(=*)\[/)
      if(m){
        let e=']'+m[1]+']',z=s.indexOf(e,i+2+m[0].length)
        z=z<0?s.length:z+e.length
        while(i<z){o+=s[i]==='\n'?'\n':' ';i++}
      }else{
        while(i<s.length&&s[i]!=='\n'){o+=' ';i++}
      }
      continue
    }
    if(c==='['){
      let m=s.slice(i).match(/^\[(=*)\[/)
      if(m){
        let e=']'+m[1]+']',z=s.indexOf(e,i+m[0].length)
        z=z<0?s.length:z+e.length
        while(i<z){o+=s[i]==='\n'?'\n':' ';i++}
        continue
      }
    }
    o+=c
    i++
  }
  return o
}

function endof(s,p){
  let q=null,eq=null,a=0,b=0,c=0
  for(let i=p;i<s.length;i++){
    let x=s[i]
    if(q){
      if(x==='\\'){i++;continue}
      if(x===q)q=null
      continue
    }
    if(eq!==null){
      let e=']'+eq+']'
      if(s.startsWith(e,i)){i+=e.length-1;eq=null}
      continue
    }
    if(x==='"'||x==="'"){q=x;continue}
    if(x==='['){
      let m=s.slice(i).match(/^\[(=*)\[/)
      if(m){eq=m[1];i+=m[0].length-1;continue}
      a++
    }else if(x===']')a--
    else if(x==='{')b++
    else if(x==='}')b--
    else if(x==='(')c++
    else if(x===')')c--
    else if((x==='\n'||x==='\r')&&a<=0&&b<=0&&c<=0)return i+1
  }
  return s.length
}

function index(s){
  let x=code(s),st=[],add=[]
  for(let i=0;i<x.length;i++){
    if(x[i]==='{')st.push(i)
    else if(x[i]==='}'&&st.length){
      let p=st.pop(),j=i+1
      while(/\s/.test(x[j]||''))j++
      if(x[j]!=='[')continue
      add.push([p,i+1])
    }
  }
  for(let [a,b] of add.sort((x,y)=>y[0]-x[0]))s=s.slice(0,b)+')'+s.slice(b),s=s.slice(0,a)+'('+s.slice(a)
  return s
}

function junk(s){
  s=s.replace(/^\s*\(["']This file was protected with MoonSec V3 by Federal#9999["']\):gsub\([\s\S]*?^end\)\s*\r?\n?/m,'')
  for(let pass=0;pass<8;pass++){
    let x=code(s),cut=null
    for(let m of x.matchAll(/^([A-Za-z_][A-Za-z0-9_]*)\s*=/gm)){
      let v=m[1]
      if(v.length<12||!/[_A-Z]/.test(v))continue
      let n=(x.match(new RegExp('\\b'+v+'\\b','g'))||[]).length
      if(n!==1)continue
      cut=[m.index,endof(s,m.index+m[0].length)]
      break
    }
    if(!cut)break
    s=s.slice(0,cut[0])+s.slice(cut[1])
  }
  return s
}

function objects(s){
  let a=s.split('\n'),cur={},all={},event={},out=[]
  let used=new Set((code(s).match(/\b[A-Za-z_][A-Za-z0-9_]*\b/g)||[]).filter(x=>!/^_FORV_\d+_$/.test(x)))
  const name=(t,line,i)=>{
    let v=t.toLowerCase().replace(/^text/,'').replace(/^ui/,'')
    if(t==='TextButton'){
      for(let j=i+1;j<Math.min(a.length,i+5);j++){
        let m=a[j].match(/\.Text\s*=\s*"([^"]+)"/)
        if(m){v=m[1].toLowerCase().replace(/[^a-z0-9]/g,'')+'button';break}
      }
    }
    if(t==='TextLabel')v='label'
    if(t==='ScreenGui')v='gui'
    if(!/^[a-z]/.test(v))v='object'
    let x=v,n=2
    while(used.has(x))x=v+n++
    used.add(x)
    return x
  }
  for(let i=0;i<a.length;i++){
    let line=a[i],types=[...line.matchAll(/Instance\.new\("([A-Za-z0-9_]+)"(?:,\s*[^)]*)?\)/g)].map(x=>x[1])
    for(let t of [...new Set(types)]){
      if(new RegExp('Instance\\.new\\("'+t+'"\\)\\.MouseButton1Click').test(line)&&all[t]?.length){
        let v=all[t][event[t]||0]||all[t][all[t].length-1]
        event[t]=(event[t]||0)+1
        line=line.replace(new RegExp('Instance\\.new\\("'+t+'"\\)','g'),v)
        continue
      }
      let fresh=!cur[t]||t!=='ScreenGui'&&new RegExp('Instance\\.new\\("'+t+'"(?:,\\s*[^)]*)?\\)\\.Parent').test(line)
      if(fresh){
        let v=name(t,line,i)
        cur[t]=v
        ;(all[t]||(all[t]=[])).push(v)
        let q=line.match(new RegExp('Instance\\.new\\("'+t+'"(?:,\\s*([^)]*))?\\)'))
        out.push('local '+v+' = Instance.new("'+t+'"'+(q&&q[1]?', '+q[1]:'')+')')
      }
      line=line.replace(new RegExp('Instance\\.new\\("'+t+'"(?:,\\s*[^)]*)?\\)','g'),cur[t])
    }
    out.push(line)
  }
  return out.join('\n')
}

function gaps(s){
  let a=s.split('\n'),out=[]
  for(let i=0;i<a.length;i++){
    let x=a[i],t=x.trim(),top=x.length===t.length
    if(top&&out.length&&out[out.length-1]&&(/^(?:local\s+function|function|for\b|while\b|if\b)/.test(t)||/^local\s+[a-z][a-z0-9]*\s*=\s*(?:Instance\.new|game:GetService)/.test(t)))out.push('')
    out.push(x.replace(/\s+$/,''))
  }
  return out.join('\n').replace(/\n{3,}/g,'\n\n')
}

function clean(s){
  s=junk(String(s).replace(/\r/g,''))
  s=s.replace(head,'')
  s=s.replace(/^\{\n([\s\S]*?)^\}:([A-Za-z_][A-Za-z0-9_]*)\(/gm,'({\n$1}):$2(')
  s=s.replace(/^(\(\{\n\s+init\s*=\s*function[\s\S]*?)(^\}\):[A-Za-z_][A-Za-z0-9_]*\()/gm,(x,a,b)=>/\n  end\s*$/.test(a)?x:a+'  end\n'+b)
  s=s.replace(/^\{(?=\s*\n)/m,'return {')
  s=s.replace(/(^|[^\w.])(\d+)\.([A-Za-z_][A-Za-z0-9_]*)/g,'$1($2).$3')
  let vl=s.split('\n')
  for(let i=0;i<vl.length;i++)if(/(^|[^.])\.\.\.(?!\.)/.test(code(vl[i]))){
    let d=(vl[i].match(/^\s*/)||[''])[0].length
    for(let j=i-1;j>=0;j--){
      let z=(vl[j].match(/^\s*/)||[''])[0].length
      if(z<d&&/\bfunction(?:\s+[^\s(]+)?\s*\(\s*\)/.test(code(vl[j]))){vl[j]=vl[j].replace(/function((?:\s+[^\s(]+)?)\s*\(\s*\)/,'function$1(...)');break}
    }
  }
  for(let i=0;i<vl.length;i++)if(/^\}\):[A-Za-z_][A-Za-z0-9_]*\(/.test(vl[i])){
    for(let j=i-1;j>=0;j--)if(vl[j]==='({'){
      if(vl.slice(j+1,i).some(x=>/^  init\s*=\s*function/.test(x))&&!/^  end\s*$/.test(vl[i-1])){vl.splice(i,0,'  end');i++}
      break
    }
    if(vl[i+1]==='({')vl[i]+=';'
  }
  s=vl.join('\n')
  let pairs=[...s.matchAll(/for\s+(_FORV_\d+_)\s*,\s*(_FORV_\d+_)\s+in\s+ipairs/g)]
  if(!pairs.length)pairs=[...s.matchAll(/for\s+(_FORV_\d+_)\s*,\s*(_FORV_\d+_)\s+in\b/g)]
  let used=new Set((code(s).match(/\b[A-Za-z_][A-Za-z0-9_]*\b/g)||[]).filter(x=>!/^_FORV_\d+_$/.test(x)))
  for(let p of pairs){
    let part=s.slice(p.index,p.index+3000)
    let a='index',b=new RegExp("CreateTab\\s*\\(\\s*"+p[2]+"|"+p[2]+"\\s*==\\s*[\"']").test(part)?'feature':'value'
    let get=x=>{let v=x,n=2;while(used.has(v))v=x+n++;used.add(v);return v}
    a=get(a);b=get(b)
    s=s.replace(new RegExp('\\b'+p[1]+'\\b','g'),a).replace(new RegExp('\\b'+p[2]+'\\b','g'),b)
  }
  let map=new Map(),an=0,un=0
  let unique=x=>{let v=x,n=2;while(used.has(v))v=x+n++;used.add(v);return v}
  for(let m of s.matchAll(/\b(_ARG_\d+_)\b/g))if(!map.has(m[1]))map.set(m[1],unique(an++?'arg'+an:'arg'))
  for(let m of s.matchAll(/\b(_UPVALUE\d+_)\b/g))if(!map.has(m[1])){
    let v=new RegExp('\\b'+m[1]+'\\.(?:Name|Team|Character)\\b').test(s)?'player':un++?'value'+un:'value'
    map.set(m[1],unique(v))
  }
  for(let [a,b] of map)s=s.replace(new RegExp('\\b'+a+'\\b','g'),b)
  s=index(objects(s))
  s=fix(s.split('\n')).join('\n')
  let mn=0
  s=s.replace(/^\(\{/gm,()=>`local module${++mn} = ({`)
  s=gaps(s.split('\n').map(n).join('\n')).trim()
  return mark+'\n\n'+s+'\n'
}

function run(s){
  let raw=String(s).replace(/\r/g,'').replace(head,'')
  let rn=0
  raw=raw.replace(/^\s*function\s+(?![A-Za-z_])[^\s(]+\s*\(/gm,()=>`local function recovered${++rn}(`)
  raw=raw.replace(/^(\s*)local\s+(var\d+)\s*=\s*(var\d+)\2\s*=\s*\2\(\)\s*end\s*$/gm,'$1local $2 = $3\n$1$2 = $2()')
  if(/\blocal\s+f\s*=\s*\{\}/.test(raw)&&/\bwhile\s+true\s+do\b/.test(raw))return String(s)
  if(!/^function\s+CRoot(?:_\d+)?\s*\(\)/.test(raw)&&!/\bvar\d+\b/.test(raw)&&/\b_FORV_\d+_|\b_ARG_\d+_|^\s*[_A-Za-z][_A-Za-z0-9]*\s*=|^\s*\(?\{/m.test(raw))return clean(raw)
  let a=raw.split('\n').map(x=>{
    x=x.replace(/=\s*local\s+(var\d+)/g,'= $1').replace(/;\s*local\s+(var\d+)/g,'; $1')
    let q=x.match(/^(\s*)((?:local\s+)?(?:var\d+|[A-Za-z_][A-Za-z0-9_.]*))\s*=\s*IDK_SHIT_WENT_MISSING_BRO\s*$/)
    if(q)return `${q[1]}${q[2]} = nil --[[ couldn't recover ]]`
    return n(x.replace(/IDK_SHIT_WENT_MISSING_BRO/g,"nil --[[ couldn't recover ]]"))
  }).flatMap(x=>{
    let q=x.match(/^(\s*)(if\b.*\bthen);\s*(.*?);\s*end\s*(.*)$/)
    if(!q)return [x]
    let m=q[3].split(/;\s*/).filter(Boolean).map(v=>q[1]+'\t'+v)
    let t=q[4].replace(/\s+local\s+/g,'\n'+q[1]+'local ')
    return [q[1]+q[2],...m,q[1]+'end',...t.split('\n').filter(Boolean)]
  })
  if(a[0]&&a[0].trim()==='function CRoot()'){
    a.shift()
    let i=a.length-1
    while(i>=0&&!a[i].trim())i--
    if(i>=0&&a[i].trim()==='end')a.splice(i,1)
    a=a.map(x=>x.startsWith('\t')?x.slice(1):x)
  }
  a=locals(a)
  a=svc(a)
  a=ctor(a)
  a=chain(a)
  a=direct(a)
  a=calls(a)
  a=tables(a)
  a=maps(a)
  a=chain(a)
  a=direct(a)
  a=smart(a)
  a=names(a)
  a=fns(a)
  a=refs(a)
  a=cb(a)
  a=fix(a)
  let body=index(a.join('\n').trim().replace(head,''))
  return mark+'\n\n'+body+'\n'
}

module.exports={run,junk,clean}

if(require.main===module){
  const fs=require('fs')
  fs.writeFileSync(process.argv[3],run(fs.readFileSync(process.argv[2],'utf8')))
}
