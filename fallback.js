const fs=require("fs")
const p=require("../pretty")
const r=require("../repair")
const f=process.argv[2]
const l=process.argv[3]||"luac"
let s=fs.readFileSync(f,"utf8")
fs.writeFileSync(f,p.run(s))
try{r.run(f,l)}catch(e){}
