-- POBUNK automatic startup
-- Extra service menu is available before the main bunker control.

if fs.exists("/bunker_extra.lua") then
    shell.run("/bunker_extra.lua")
end

if fs.exists("/bunker.lua") then
    shell.run("/bunker.lua")
else
    print("POBUNK is not installed.")
    print("Run: wget run https://raw.githubusercontent.com/Frez7373/POBUNK/main/install.lua")
end
