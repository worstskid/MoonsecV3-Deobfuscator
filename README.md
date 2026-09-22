<p align="center">
  <img src="./banner.png" alt="MoonsecV3 Deobfuscator">
</p>

<h1 align="center">MoonsecV3 Deobfuscator</h1>
<p align="center">
  [this project isn't actually open source. Read LICENSE for details]
</p>
<p align="center">
  Reconstruct MoonsecV3-obfuscated Lua back into readable, understandable source.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Lua-2C2D72?style=flat-square&logo=lua&logoColor=white">
  <img src="https://img.shields.io/badge/Node.js-required-339933?style=flat-square&logo=node.js&logoColor=white">
</p>

## About

MoonsecV3 Deobfuscator is a Lua-based deobfuscation tool by wrostskid / sergei.dev designed to reconstruct MoonsecV3-protected Lua code into readable source.

Rather than simply dumping VM instructions or displaying a low-level instruction listing, the project focuses on **reconstructing the original program structure** into Lua that can actually be read and analyzed.

### Highlights

* Supports known MoonsecV3 VM variants
* Reconstructs code into readable Lua
* Goes beyond raw VM instruction dumping
* Lua-based implementation
* Node.js fallback for additional processing
* Node.js-assisted output formatting
* Designed for analysis and reverse engineering

## Requirements

* Lua
* Node.js

Node.js is used as a fallback for certain operations and for additional output processing/formatting.

## Usage

```bash
lua moonsec\Lua\cli.lua input.lua output.lua
```

See the documentation and examples for the currently supported input formats and options.

## How It Works

The deobfuscator analyzes the VM structure produced by MoonsecV3, identifies the underlying operations and control flow, and reconstructs them into a higher-level Lua representation.

The goal is not simply:

```text
obfuscated Lua
    ↓
VM instructions
```

but rather:

```text
obfuscated Lua
    ↓
VM analysis
    ↓
instruction reconstruction
    ↓
control-flow reconstruction
    ↓
Lua reconstruction
    ↓
readable Lua
```

This makes the resulting output substantially easier to inspect and understand than a raw instruction dump.

## Project Status

This project is actively being developed.

VM variants and edge cases are continually being identified and improved as the deobfuscator evolves.

## Legal Notice

This project is provided for educational, research, and authorized reverse-engineering purposes.

Only use it on software and code that you have permission to analyze.

## License

This project is **source-available** and is **not open source**.

See [`LICENSE`](./LICENSE) for the terms governing use, copying, modification, and redistribution.

Copyright © 2026
