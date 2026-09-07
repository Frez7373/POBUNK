-- OSBUNK INSTALLER 2.0
-- CC:Tweaked / Minecraft 1.21.1
-- Install with:
-- wget run https://raw.githubusercontent.com/Frez7373/POBUNK/main/install.lua

local BASE="https://raw.githubusercontent.com/Frez7373/POBUNK/main/"
local files={
 {"config.lua","/config.lua"},
 {"osbunk.lua","/osbunk.lua"},
 {"startup.lua","/startup.lua"}
}

term.clear(); term.setCursorPos(1,1)
print("========================================")
print("           OSBUNK INSTALLER 2.0         ")
print("========================================")
print("Target: CC:Tweaked / Minecraft 1.21.1")
print("")

local function get(url)
 if not http or not http.get then return nil,"HTTP API disabled" end
 local ok,h=pcall(http.get,url)
 if not ok or not h then return nil,"download failed" end
 local s=h.readAll(); h.close(); return s
end

local function save(path,data)
 local h=fs.open(path,"w"); if not h then return false end; h.write(data); h.close(); return true end

print("[1/4] Preparing...")
if fs.exists("/startup.lua") then fs.makeDir("/osbunk_backup"); fs.copy("/startup.lua","/osbunk_backup/startup.lua") end
if fs.exists("/bunker.lua") then fs.copy("/bunker.lua","/osbunk_backup/bunker.lua") end
if fs.exists("/config.lua") then fs.copy("/config.lua","/osbunk_backup/config.lua") end

for i,v in ipairs(files) do
 print("["..(i+1).."/4] "..v[2])
 local data,err=get(BASE..v[1])
 if not data then print("ERROR: "..tostring(err)); print("Installation stopped."); return end
 if not save(v[2],data) then print("ERROR: cannot write "..v[2]); return end
 print("       OK")
end

fs.makeDir("/osbunk_backups")
print("[4/4] Finalizing...")
print("")
print("OSBUNK 2.0 installed successfully!")
print("Default PIN: 2580")
print("")
print("Hardware supported:")
print("  monitor / touchscreen")
print("  modem / rednet")
print("  printer")
print("  disk drive")
print("  speaker")
print("  redstone bunker controls")
print("  inventory peripherals")
print("")
print("Restart the computer to start OSBUNK.")
