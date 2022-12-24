## Friday Night Funkin' - Echo Engine

A little Psych Engine Addon

# THIS ISN'T AN ENTIRE MOD/FORK OF PSYCH ENGINE, DON'T GET CONFUSED.

join our discord! https://discord.gg/MaCw7gQ8

## Installation
You must have a [ update to date version of haxe. ](https://haxe.org/download/)
Then,you'll need to follow the fnf source code compilation tutorial,after that you can install LuaJIT
to install LuaJIT copy this:`haxelib git linc_luajit https://github.com/nebulazorua/linc_luajit`on a command prompt/powershell.
So if your lazy as fuck and don't want your mod to be able to run LUA scripts delete "LUA_ALLOWED"line in project.xml.
If you get a error while running lua, run:`haxelib remove linc_luajit`into command prompt/powershell,and then reinstall luaJIT.
If you want video support on your mod, simply do:`haxelib install hxCodec` on a Command prompt/PowerShell.
otherwise, you can delete the "VIDEOS_ALLOWED" Line on Project.xml

## Compile instructions

Just replace this with normal psych files then compile psych normally

If you don't now how to compile psych read this

Install Haxe: https://haxe.org/download/

Install Git: https://git-scm.com/download/win

Install Visual Studio Code: https://code.visualstudio.com

Now install this libraries in a cmd (in order)
```
haxelib install lime

haxelib install openfl

haxelib install flixel

haxelib install flixel-tools

haxelib run lime setup flixel

haxelib run lime setup

haxelib run flixel-tools setup

haxelib run openfl setup

haxelib git linc_luajit https://github.com/nebulazorua/linc_luajit

haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc

haxelib git linc_lua https://github.com/kevinresol/linc_lua

haxelib install hxCodec

haxelib install hscript

haxelib git faxe https://github.com/ashea-code/faxe

haxelib install newgrounds

haxelib install hxcpp-debug-server

haxelib install HtmlParser

haxelib git hxvm-luajit https://github.com/nebulazorua/hxvm-luajit

haxelib install tjson

haxelib install random

haxelib install hxp

haxelib install xmlTools

haxelib install hxnodejs

haxelib install hxjsonast

haxelib install systools

haxelib update [libraries above without brackets]
```

## Creators
* MyFnf - Main Programmer
* MemeHoovy - Main Bug Fixer
* aislanbclaudino - added features to dad battle
* Slac - Artist
## Contributors

* WarlyFarly-Github - MacOS Tester
* ShadowKnuckles - Concept makeer/Adding extra features

## CODE

* BeastlyGhost - Legacy Chart Support
* magnumsrt - Phyton Support
