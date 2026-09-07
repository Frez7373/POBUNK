-- OSBUNK 2.0 - Bunker Operating System
-- CC:Tweaked / Minecraft 1.21.1

local cfg = {
 name="OSBUNK", version="2.0.0", pin="2580", monitor_side="top",
 bunker={door="front",lights="back",ventilation="left",alarm="bottom"}
}
if fs.exists("/config.lua") then local ok,x=pcall(dofile,"/config.lua"); if ok and type(x)=="table" then for k,v in pairs(x) do cfg[k]=v end end end

local mon = peripheral.find("monitor")
local screen = mon or term.current()
if mon then pcall(mon.setTextScale,0.5) end

local S={locked=true,door=true,lights=true,vent=true,alarm=false,lockdown=false,start=false}
local logs={"OSBUNK BOOT  "..os.date("%H:%M:%S")}
local pin=""

local function tclear() screen.setBackgroundColor(colors.black); screen.setTextColor(colors.white); screen.clear(); screen.setCursorBlink(false) end
local function tx(x,y,s,c,b) if b then screen.setBackgroundColor(b) end; if c then screen.setTextColor(c) end; screen.setCursorPos(x,y); screen.write(tostring(s):sub(1,math.max(0,screen.getSize()-x+1))) end
local function box(x,y,w,h,c) screen.setBackgroundColor(c); for i=0,h-1 do screen.setCursorPos(x,y+i); screen.write(string.rep(" ",w)) end end
local function btn(x,y,w,h,s,c,fg) box(x,y,w,h,c or colors.gray); local xx=x+math.max(0,math.floor((w-#s)/2)); tx(xx,y+math.floor(h/2),s,fg or colors.white,c or colors.gray) end
local function center(y,s,c,b) local w=screen.getSize(); tx(math.max(1,math.floor((w-#s)/2)+1),y,s,c,b) end
local function log(s) table.insert(logs,1,os.date("%H:%M:%S").."  "..s); while #logs>80 do table.remove(logs) end end
local function notify(s) local sp=peripheral.find("speaker"); if sp then pcall(sp.playNote,"pling",0.4,12) end; log(s) end
local function output(k,v) local side=cfg.bunker and cfg.bunker[k]; if side and side~="none" then redstone.setOutput(side,v) end end
local function apply() output("door",S.door); output("lights",S.lights); output("ventilation",S.vent); output("alarm",S.alarm) end
local function setdoor(v) if S.lockdown and not v then notify("LOCKDOWN: DOOR LOCKED"); return end; S.door=v; output("door",v); log(v and "DOOR LOCKED" or "DOOR OPEN") end
local function lockdown() S.lockdown=true; S.door=true; S.lights=true; S.vent=true; S.alarm=true; apply(); notify("!!! LOCKDOWN ACTIVE !!!") end
local function clearlock() S.lockdown=false; S.alarm=false; output("alarm",false); notify("LOCKDOWN CLEARED") end
local function dtype(n) local x=peripheral.getType(n); return type(x)=="table" and table.concat(x,",") or tostring(x) end
local function has(n) return #peripheral.find(n)>0 end

local function header(title)
 local w=screen.getSize(); box(1,1,w,2,colors.blue); tx(2,1,cfg.name.." // "..cfg.version,colors.white,colors.blue); tx(2,2,title,colors.white,colors.blue)
end

local function lockScreen()
 tclear(); local w,h=screen.getSize(); box(1,1,w,3,colors.blue); center(2,"OSBUNK SECURITY",colors.white,colors.blue); center(5,"ENTER PIN",colors.cyan)
 center(6,string.rep("•",#pin),colors.white)
 local k={{"1",2,8},{"2",12,8},{"3",22,8},{"4",2,11},{"5",12,11},{"6",22,11},{"7",2,14},{"8",12,14},{"9",22,14},{"CLR",2,17},{"0",12,17},{"OK",22,17}}
 for _,v in ipairs(k) do btn(v[2],v[3],8,2,v[1],colors.gray) end
 center(math.min(h,20),"Keyboard: digits + ENTER | Q = stop",colors.lightGray)
end

local apps={
 {"CTRL","Control Center"},{"HW","Hardware"},{"NET","Network"},{"PRINT","Printer"},{"DRIVE","Disk Drive"},{"LOG","Event Log"},{"FILE","Files"},{">_","Console"}
}
local function desktop()
 tclear(); local w,h=screen.getSize(); header("BUNKER DESKTOP")
 for i,a in ipairs(apps) do local x=2+((i-1)%4)*14; local y=4+math.floor((i-1)/4)*5; if y<h-3 then btn(x,y,11,3,a[1],colors.gray); tx(x,y+3,a[2],colors.white) end end
 box(1,h-3,w,3,colors.blue); btn(2,h-2,9,2,"START",colors.lightBlue,colors.black); tx(14,h-2,S.lockdown and "LOCKDOWN" or "SECURE",S.lockdown and colors.red or colors.lime,colors.blue); tx(28,h-2,"DEV:"..#peripheral.getNames(),colors.white,colors.blue); tx(math.max(1,w-10),1,os.date("%H:%M:%S"),colors.white,colors.blue)
end
local function hitApp(x,y)
 local h=screen.getSize(); if y>=h-2 and y<=h-1 and x>=2 and x<11 then return "START" end
 for i,a in ipairs(apps) do local xx=2+((i-1)%4)*14; local yy=4+math.floor((i-1)/4)*5; if x>=xx and x<xx+11 and y>=yy and y<yy+4 then return a[1] end end
end

local function control()
 while true do
  tclear(); local w,h=screen.getSize(); header("CONTROL CENTER");
  tx(2,4,"DOOR",colors.cyan); tx(18,4,S.door and "LOCKED" or "OPEN",S.door and colors.lime or colors.yellow)
  tx(2,5,"LIGHTS",colors.cyan); tx(18,5,S.lights and "ON" or "OFF",S.lights and colors.lime or colors.lightGray)
  tx(2,6,"VENTILATION",colors.cyan); tx(18,6,S.vent and "ON" or "OFF",S.vent and colors.lime or colors.yellow)
  tx(2,7,"ALARM",colors.cyan); tx(18,7,S.alarm and "ACTIVE" or "CLEAR",S.alarm and colors.red or colors.lime)
  btn(2,9,14,2,"DOOR",colors.gray); btn(18,9,14,2,"LIGHTS",colors.gray); btn(2,12,14,2,"VENT",colors.gray); btn(18,12,14,2,"ALARM",colors.gray); btn(2,15,30,2,S.lockdown and "CLEAR LOCKDOWN" or "EMERGENCY LOCKDOWN",S.lockdown and colors.orange or colors.red)
  tx(2,h-1,"D/L/V/A toggle | E emergency | ESC back",colors.lightGray)
  local e={os.pullEvent()}; if e[1]=="key" then if e[2]==keys.esc then return elseif e[2]==keys.d then setdoor(not S.door) elseif e[2]==keys.l then S.lights=not S.lights; output("lights",S.lights) elseif e[2]==keys.v then S.vent=not S.vent; output("ventilation",S.vent) elseif e[2]==keys.a then S.alarm=not S.alarm; output("alarm",S.alarm) elseif e[2]==keys.e then if S.lockdown then clearlock() else lockdown() end end elseif e[1]=="mouse_click" or e[1]=="monitor_touch" then local x,y=e[3],e[4]; if y>=9 and y<=10 and x<16 then setdoor(not S.door) elseif y>=9 and y<=10 and x>=18 then S.lights=not S.lights; output("lights",S.lights) elseif y>=12 and y<=13 and x<16 then S.vent=not S.vent; output("ventilation",S.vent) elseif y>=12 and y<=13 and x>=18 then S.alarm=not S.alarm; output("alarm",S.alarm) elseif y>=15 and y<=16 then if S.lockdown then clearlock() else lockdown() end end end
 end
end

local function hardware()
 while true do
  tclear(); local w,h=screen.getSize(); header("HARDWARE INVENTORY"); local y=4
  for _,n in ipairs(peripheral.getNames()) do if y<=h-3 then tx(2,y,n,colors.cyan); tx(20,y,dtype(n),colors.white); y=y+1 end end
  if y==4 then tx(2,y,"No peripherals detected",colors.yellow) end; tx(2,h-1,"ESC back",colors.lightGray); local e={os.pullEvent("key")}; if e[2]==keys.esc then return end
 end
end

local function network()
 local m=peripheral.find("modem"); if not m then tclear(); header("NETWORK"); tx(2,5,"No modem detected",colors.yellow); sleep(2); return end
 local side=peripheral.getName(m); rednet.open(side)
 while true do
  tclear(); local w,h=screen.getSize(); header("NETWORK"); tx(2,4,"MODEM",colors.cyan); tx(18,4,side,colors.lime); tx(2,5,"Computer ID",colors.cyan); tx(18,5,os.getComputerID(),colors.white); tx(2,6,"Channel",colors.cyan); tx(18,6,"OSBUNK",colors.white); btn(2,9,28,2,"BROADCAST HELLO",colors.gray); btn(2,12,28,2,"PING SELF",colors.gray); tx(2,h-1,"ESC back",colors.lightGray)
  local e={os.pullEvent()}; if e[1]=="key" and e[2]==keys.esc then rednet.close(side); return elseif e[1]=="mouse_click" or e[1]=="monitor_touch" then if e[4]>=9 and e[4]<=10 then rednet.broadcast("OSBUNK ONLINE ID="..os.getComputerID(),"OSBUNK"); notify("Broadcast sent") elseif e[4]>=12 and e[4]<=13 then notify("Network OK") end end
 end
end

local function printer()
 local p=peripheral.find("printer"); tclear(); header("PRINTER"); if not p then tx(2,5,"Printer not found",colors.yellow); sleep(2); return end
 local ink=pcall(function() return p.getInkLevel() end) and p.getInkLevel() or "?"; local paper=pcall(function() return p.getPaperLevel() end) and p.getPaperLevel() or "?"
 tx(2,5,"INK",colors.cyan); tx(16,5,ink,colors.white); tx(2,6,"PAPER",colors.cyan); tx(16,6,paper,colors.white); btn(2,9,28,2,"PRINT SYSTEM REPORT",colors.gray); tx(2,13,"ESC back",colors.lightGray)
 while true do local e={os.pullEvent()}; if e[1]=="key" and e[2]==keys.esc then return elseif (e[1]=="mouse_click" or e[1]=="monitor_touch") and e[4]>=9 and e[4]<=10 then if not p.newPage() then notify("Printer: no paper/ink") else p.setPageTitle("OSBUNK Report"); p.write("OSBUNK "..cfg.version); p.setCursorPos(1,3); p.write("Computer ID: "..os.getComputerID()); p.setCursorPos(1,5); p.write("Time: "..os.date()); p.setCursorPos(1,7); p.write("Peripherals: "..#peripheral.getNames()); p.setCursorPos(1,9); p.write("Door: "..(S.door and "LOCKED" or "OPEN")); p.setCursorPos(1,10); p.write("Lights: "..(S.lights and "ON" or "OFF")); p.setCursorPos(1,11); p.write("Vent: "..(S.vent and "ON" or "OFF")); p.setCursorPos(1,12); p.write("Alarm: "..(S.alarm and "ACTIVE" or "CLEAR")); if p.endPage() then notify("Report printed") else notify("Print failed") end end end end
end

local function driveApp()
 local d=peripheral.find("drive"); tclear(); header("DISK DRIVE"); if not d then tx(2,5,"Disk drive not found",colors.yellow); sleep(2); return end
 while true do
  local hasDisk=pcall(function() return d.hasData() end) and d.hasData() or false; tclear(); header("DISK DRIVE"); tx(2,5,"Drive",colors.cyan); tx(16,5,peripheral.getName(d),colors.white); tx(2,6,"Disk",colors.cyan); tx(16,6,hasDisk and "INSERTED" or "EMPTY",hasDisk and colors.lime or colors.yellow); if hasDisk then local l=d.getMountPath(); tx(2,8,"Mount",colors.cyan); tx(16,8,l or "?",colors.white) end; tx(2,12,"ESC back",colors.lightGray); local e={os.pullEvent()}; if e[1]=="key" and e[2]==keys.esc then return end end
end

local function logsApp()
 tclear(); local w,h=screen.getSize(); header("EVENT LOG"); for i=1,math.min(#logs,h-4) do tx(2,2+i,logs[i],i==1 and colors.yellow or colors.lightGray) end; tx(2,h-1,"ESC back",colors.lightGray); while true do local e={os.pullEvent("key")}; if e[2]==keys.esc then return end end
end

local function files()
 local path="/"; local idx=1
 while true do
  tclear(); local w,h=screen.getSize(); header("FILES  "..path); local list=fs.list(path); table.sort(list); for i,n in ipairs(list) do if i<=h-6 then tx(2,2+i,(fs.isDir(fs.combine(path,n)) and "[DIR] " or "      ")..n,i==idx and colors.cyan or colors.white,i==idx and colors.gray or colors.black) end end; tx(2,h-1,"UP/DOWN select | ENTER open | BACKSPACE up | ESC",colors.lightGray)
  local e={os.pullEvent()}; if e[1]=="key" then if e[2]==keys.esc then return elseif e[2]==keys.up then idx=math.max(1,idx-1) elseif e[2]==keys.down then idx=math.min(math.max(1,#list),idx+1) elseif e[2]==keys.backspace then if path~="/" then path=fs.getDir(path); if path=="" then path="/" end; idx=1 end elseif e[2]==keys.enter and list[idx] and fs.isDir(fs.combine(path,list[idx])) then path=fs.combine(path,list[idx]); idx=1 end end end
end

local function console() shell.run("shell") end

local function startMenu()
 state.start=true; while state.start do desktop(); local w,h=screen.getSize(); box(2,h-18,34,16,colors.gray); tx(4,h-17,"OSBUNK START",colors.white,colors.gray); for i,a in ipairs(apps) do local y=h-15+((i-1)%8)*2; local x=4+(math.floor((i-1)/8)*15); tx(x,y,a[1],colors.white,colors.gray); tx(x+5,y,a[2]:sub(1,9),colors.white,colors.gray) end; tx(4,h-3,"L lock | ESC close",colors.lightGray,colors.gray); local e={os.pullEvent()}; if e[1]=="key" then if e[2]==keys.esc then state.start=false elseif e[2]==keys.l then state.locked=true; state.start=false end elseif e[1]=="mouse_click" or e[1]=="monitor_touch" then local found=nil; for i,a in ipairs(apps) do local y=h-15+((i-1)%8)*2; local x=4+(math.floor((i-1)/8)*15); if e[4]==y and e[3]>=x and e[3]<x+14 then found=a[1] end end; if found then state.start=false; return found end end end end
end

apply()
while true do
 if S.locked then lockScreen() else desktop() end
 local e={os.pullEvent()}
 if S.locked then
  if e[1]=="key" then if e[2]==keys.enter then if pin==tostring(cfg.pin) then S.locked=false; pin=""; notify("ACCESS GRANTED") else pin=""; notify("INVALID PIN") end elseif e[2]==keys.backspace then pin=pin:sub(1,-2) elseif e[2]>=keys.zero and e[2]<=keys.nine and #pin<12 then pin=pin..tostring(e[2]-keys.zero) elseif e[2]==keys.q then break end elseif e[1]=="mouse_click" or e[1]=="monitor_touch" then local x,y=e[3],e[4]; local keys2={{"1",2,8},{"2",12,8},{"3",22,8},{"4",2,11},{"5",12,11},{"6",22,11},{"7",2,14},{"8",12,14},{"9",22,14},{"CLR",2,17},{"0",12,17},{"OK",22,17}}; for _,k in ipairs(keys2) do if x>=k[2] and x<k[2]+8 and y>=k[3] and y<k[3]+2 then if k[1]=="CLR" then pin="" elseif k[1]=="OK" then if pin==tostring(cfg.pin) then S.locked=false; pin=""; notify("ACCESS GRANTED") else pin=""; notify("INVALID PIN") end else pin=pin..k[1] end end end end
 else
  if e[1]=="key" then if e[2]==keys.q then break elseif e[2]==keys.l then S.locked=true elseif e[2]==keys.e then lockdown() end elseif e[1]=="mouse_click" or e[1]=="monitor_touch" then local id=hitApp(e[3],e[4]); if id=="START" then local a=startMenu(); if a then if a=="CTRL" then control() elseif a=="HW" then hardware() elseif a=="NET" then network() elseif a=="PRINT" then printer() elseif a=="DRIVE" then driveApp() elseif a=="LOG" then logsApp() elseif a=="FILE" then files() elseif a==">_" then console() end end elseif id=="CTRL" then control() elseif id=="HW" then hardware() elseif id=="NET" then network() elseif id=="PRINT" then printer() elseif id=="DRIVE" then driveApp() elseif id=="LOG" then logsApp() elseif id=="FILE" then files() elseif id==">_" then console() end end end
end
