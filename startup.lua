-- OSBUNK automatic startup
-- CC:Tweaked / Minecraft 1.21.1

if fs.exists("/osbunk.lua") then
    shell.run("/osbunk.lua")
elseif fs.exists("/bunker.lua") then
    print("OSBUNK is missing. Starting legacy POBUNK...")
    sleep(1)
    shell.run("/bunker.lua")
else
    print("POBUNK/OSBUNK is not installed.")
    print("Run:")
    print("wget run https://raw.githubusercontent.com/Frez7373/POBUNK/main/install.lua")
end
