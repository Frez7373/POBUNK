-- POBUNK HARDWARE CENTER
-- CC:Tweaked 1.16.5
-- Auto-detects printer, modem/router, disk drive and speaker.

local monitor = peripheral.find("monitor")
local t = monitor or term
if monitor then monitor.setTextScale(1) end

local function clear() t.setBackgroundColor(colors.black); t.setTextColor(colors.white); t.clear() end
local function title(s) local w=t.getSize(); t.setBackgroundColor(colors.blue); t.setTextColor(colors.white); t.setCursorPos(1,1); t.clearLine(); t.write(("  "..s):sub(1,w)) end
local function btn(x,y,w,h,label,c) local tw,th=t.getSize(); if x>tw or y>th then return end; w=math.min(w,tw-x+1); h=math.min(h,th-y+1); t.setBackgroundColor(c or colors.gray); for yy=y,y+h-1 do t.setCursorPos(x,yy); t.write(string.rep(" ",w)) end; t.setTextColor(colors.white); t.setCursorPos(x+math.max(0,math.floor((w-#label)/2)),y+math.floor(h/2)); t.write(label:sub(1,w)) end
local function findTypes(types) local out={}; for _,name in ipairs(peripheral.getNames()) do local typ=peripheral.getType(name) or "unknown"; for _,wanted in ipairs(types) do if typ==wanted then table.insert(out,{name=name,type=typ}); break end end end; return out end
local function waitBack(y)
 while true do local e={os.pullEvent()}; if e[1]=="key" and (e[2]==keys.q or e[2]==keys.enter) then return end; if e[1]=="monitor_touch" and monitor and e[2]==peripheral.getName(monitor) and e[4]>=y and e[4]<=y+1 then return end end
end
local function printTest(dev)
 clear(); title("POBUNK // PRINTER TEST"); t.setCursorPos(2,3); t.write("Printer: "..dev); local p=peripheral.wrap(dev); local ok,msg=pcall(function() if not p.newPage then error("Unsupported printer API") end; p.newPage(); p.setPageTitle("POBUNK TEST"); p.write("POBUNK HARDWARE TEST"); p.newLine(); p.write("Printer: "..dev); p.newLine(); p.write("Status: ONLINE"); p.endPage() end); t.setCursorPos(2,6); t.setTextColor(ok and colors.lime or colors.red); t.write(ok and "TEST PAGE SENT" or ("ERROR: "..tostring(msg)):sub(1,45)); btn(2,9,16,2,"BACK",colors.gray); waitBack(9)
end
local function speakerTest(dev)
 clear(); title("POBUNK // SPEAKER TEST"); t.setCursorPos(2,3); t.write("Speaker: "..dev); local s=peripheral.wrap(dev); local ok,msg=pcall(function() if s.playNote then s.playNote("harp",1,12); sleep(0.25); s.playNote("pling",1,16) elseif s.playSound then s.playSound("minecraft:block.note_block.pling",1,1) else error("Unsupported speaker API") end end); t.setCursorPos(2,6); t.setTextColor(ok and colors.lime or colors.red); t.write(ok and "TEST SOUND PLAYED" or ("ERROR: "..tostring(msg)):sub(1,45)); btn(2,9,16,2,"BACK",colors.gray); waitBack(9)
end
local function driveInfo(dev)
 clear(); title("POBUNK // DISK DRIVE"); t.setCursorPos(2,3); t.write("Drive: "..dev); local d=peripheral.wrap(dev); local methods={"isDiskPresent","getDiskID","getDiskLabel","hasAudio","getAudioTitle"}; local y=5; for _,m in ipairs(methods) do local fn=d[m]; if fn then local ok,val=pcall(fn); if ok then t.setCursorPos(2,y); t.write(m..": "..tostring(val)); y=y+1 end end end; btn(2,12,16,2,"BACK",colors.gray); waitBack(12)
end
local function modemInfo(dev)
 clear(); title("POBUNK // MODEM / ROUTER"); local m=peripheral.wrap(dev); local typ=peripheral.getType(dev); t.setCursorPos(2,3); t.write("Device: "..dev); t.setCursorPos(2,4); t.write("Type: "..tostring(typ)); local wireless=false; if m.isWireless then pcall(function() wireless=m.isWireless() end) end; t.setCursorPos(2,5); t.write("Wireless: "..tostring(wireless)); local open={}; if m.getOpenChannels then pcall(function() open=m.getOpenChannels() end) end; t.setCursorPos(2,6); t.write("Open channels: "); local parts={}; for _,ch in ipairs(open) do parts[#parts+1]=tostring(ch) end; t.setCursorPos(2,7); t.write(#parts>0 and table.concat(parts,", ") or "none"); btn(2,10,16,2,"BACK",colors.gray); waitBack(10)
end
local function hardwareList()
 while true do
  clear(); title("POBUNK // HARDWARE CENTER")
  local printers=findTypes({"printer"}); local speakers=findTypes({"speaker"}); local drives=findTypes({"drive"}); local modems=findTypes({"modem","wired_modem","wireless_modem","router"}); local w,h=t.getSize()
  t.setCursorPos(2,3); t.write("PRINTERS: "..#printers); local y=4; for _,d in ipairs(printers) do btn(2,y,34,2,"PRINTER "..d.name,colors.green); y=y+3 end
  t.setCursorPos(2,y); t.write("SPEAKERS: "..#speakers); y=y+1; local sy=y; for _,d in ipairs(speakers) do btn(2,y,34,2,"SPEAKER "..d.name,colors.green); y=y+3 end
  if w>=40 then
   local x=40; t.setCursorPos(x,3); t.write("DISK DRIVES: "..#drives); local yy=4; for _,d in ipairs(drives) do btn(x,yy,math.min(28,w-x+1),2,"DRIVE "..d.name,colors.blue); yy=yy+3 end
   t.setCursorPos(x,yy); t.write("MODEMS / ROUTERS: "..#modems); yy=yy+1; local ny=yy; for _,d in ipairs(modems) do btn(x,yy,math.min(28,w-x+1),2,"NETWORK "..d.name,colors.blue); yy=yy+3 end
  end
  btn(2,h-2,16,2,"BACK",colors.gray)
  local e={os.pullEvent()}
  if e[1]=="key" and e[2]==keys.q then return end
  if e[1]=="monitor_touch" and monitor and e[2]==peripheral.getName(monitor) then
   local tx,ty=e[3],e[4]; if ty>=h-2 then return end
   local py=4; for _,d in ipairs(printers) do if ty>=py and ty<=py+1 then printTest(d.name); break end; py=py+3 end
   local sy2=sy; for _,d in ipairs(speakers) do if ty>=sy2 and ty<=sy2+1 then speakerTest(d.name); break end; sy2=sy2+3 end
   if tx>=40 then local dy=4; for _,d in ipairs(drives) do if ty>=dy and ty<=dy+1 then driveInfo(d.name); break end; dy=dy+3 end; local ny2=ny; for _,d in ipairs(modems) do if ty>=ny2 and ty<=ny2+1 then modemInfo(d.name); break end; ny2=ny2+3 end end
  elseif e[1]=="mouse_click" and t==term then return end
 end
end
hardwareList()
