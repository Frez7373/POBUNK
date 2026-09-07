-- POBUNK EXTRA CONTROL PANEL
-- CC:Tweaked 1.16.5
-- Service/monitoring menu with hardware support.

local monitor=peripheral.find("monitor")
local t=monitor or term
if monitor then monitor.setTextScale(1) end
local function clear() t.setBackgroundColor(colors.black); t.setTextColor(colors.white); t.clear() end
local function title(s) local w=t.getSize(); t.setBackgroundColor(colors.blue); t.setTextColor(colors.white); t.setCursorPos(1,1); t.clearLine(); t.write(("  "..s):sub(1,w)) end
local function btn(x,y,w,h,label,c) local tw,th=t.getSize(); if x>tw or y>th then return end; w=math.min(w,tw-x+1); h=math.min(h,th-y+1); t.setBackgroundColor(c or colors.gray); for yy=y,y+h-1 do t.setCursorPos(x,yy); t.write(string.rep(" ",w)) end; t.setTextColor(colors.white); t.setCursorPos(x+math.max(0,math.floor((w-#label)/2)),y+math.floor(h/2)); t.write(label:sub(1,w)) end
local function outputState(side) if side=="none" then return "OFF" end; return redstone.getOutput(side) and "ON" or "OFF" end
local function inputState(side) if side=="none" then return "OFF" end; return redstone.getInput(side) and "ACTIVE" or "CLEAR" end
local function waitBack(y) while true do local e={os.pullEvent()}; if e[1]=="key" and (e[2]==keys.q or e[2]==keys.enter) then return end; if e[1]=="monitor_touch" and monitor and e[2]==peripheral.getName(monitor) and e[4]>=y and e[4]<=y+1 then return end end end
local function showDiagnostics()
 clear(); title("POBUNK // DIAGNOSTICS"); local w,h=t.getSize(); t.setCursorPos(2,3); t.write("Computer ID: "..os.getComputerID()); t.setCursorPos(2,4); t.write("Label: "..(os.getComputerLabel() or "UNNAMED")); t.setCursorPos(2,5); t.write("Time: "..os.date("%H:%M:%S")); t.setCursorPos(2,7); t.write("PERIPHERALS"); local y=8; for _,name in ipairs(peripheral.getNames()) do t.setCursorPos(2,y); t.write(name.." ["..tostring(peripheral.getType(name)).."]"); y=y+1; if y>h-4 then break end end; btn(2,h-2,16,2,"BACK",colors.gray); waitBack(h-2)
end
local function showSensors()
 clear(); title("POBUNK // SENSOR MONITOR"); local sides={"top","bottom","left","right","front","back"}; t.setCursorPos(2,3); t.write("REDSTONE INPUTS"); local y=4; for _,s in ipairs(sides) do t.setCursorPos(2,y); t.write(string.format("%-6s : %s",s,inputState(s))); y=y+1 end; t.setCursorPos(22,3); t.write("REDSTONE OUTPUTS"); y=4; for _,s in ipairs(sides) do t.setCursorPos(22,y); t.write(string.format("%-6s : %s",s,outputState(s))); y=y+1 end; local _,h=t.getSize(); btn(2,h-2,16,2,"BACK",colors.gray); waitBack(h-2)
end
local function hardware() shell.run("/hardware.lua") end
local function menu()
 while true do
  clear(); title("POBUNK // SERVICE MENU"); local w,h=t.getSize(); t.setTextColor(colors.lightGray); t.setCursorPos(2,3); t.write("Additional bunker functions")
  btn(2,5,30,2,"DIAGNOSTICS",colors.blue); btn(2,8,30,2,"SENSOR MONITOR",colors.blue); btn(2,11,30,2,"HARDWARE CENTER",colors.green); btn(2,14,30,2,"OPEN MAIN CONTROL",colors.gray); btn(2,17,30,2,"REBOOT",colors.orange)
  local e={os.pullEvent()}
  if e[1]=="key" then if e[2]==keys.one then showDiagnostics() elseif e[2]==keys.two then showSensors() elseif e[2]==keys.three then hardware() elseif e[2]==keys.four then shell.run("/bunker.lua"); return elseif e[2]==keys.five then os.reboot() elseif e[2]==keys.q then return end
  elseif e[1]=="monitor_touch" and monitor and e[2]==peripheral.getName(monitor) then local y=e[4]; if y>=5 and y<=6 then showDiagnostics() elseif y>=8 and y<=9 then showSensors() elseif y>=11 and y<=12 then hardware() elseif y>=14 and y<=15 then shell.run("/bunker.lua"); return elseif y>=17 and y<=18 then os.reboot() end
  elseif e[1]=="mouse_click" and t==term then local y=e[4]; if y>=5 and y<=6 then showDiagnostics() elseif y>=8 and y<=9 then showSensors() elseif y>=11 and y<=12 then hardware() elseif y>=14 and y<=15 then shell.run("/bunker.lua"); return elseif y>=17 and y<=18 then os.reboot() end end
 end
end
menu()
