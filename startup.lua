-- POBUNK automatic startup
if fs.exists("/bunker.lua") then
    shell.run("/bunker.lua")
else
    print("POBUNK is not installed.")
    print("Run: wget run https://raw.githubusercontent.com/Frez7373/POBUNK/main/install.lua")
end
