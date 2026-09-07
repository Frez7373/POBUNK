-- POBUNK INSTALLER
-- Run with:
-- wget run https://raw.githubusercontent.com/Frez7373/POBUNK/main/install.lua

local BASE = "https://raw.githubusercontent.com/Frez7373/POBUNK/main/"
local files = {
    {url=BASE.."config.lua", path="/config.lua"},
    {url=BASE.."bunker.lua", path="/bunker.lua"},
    {url=BASE.."bunker_extra.lua", path="/bunker_extra.lua"},
    {url=BASE.."diagnostics.lua", path="/diagnostics.lua"},
    {url=BASE.."hardware.lua", path="/hardware.lua"},
    {url=BASE.."startup.lua", path="/startup.lua"}
}

term.clear(); term.setCursorPos(1,1)
print("================================")
print("        POBUNK INSTALLER        ")
print("================================")
print("CC:Tweaked 1.16.5")
print("")

local function download(url, path)
    if not http then error("HTTP API is disabled. Enable HTTP in the computer config.") end
    write("Installing " .. path .. " ... ")
    local ok, result = pcall(function() return http.get(url) end)
    if not ok or not result then print("FAILED"); return false end
    local data = result.readAll(); result.close()
    local f = fs.open(path, "w")
    f.write(data); f.close()
    print("OK")
    return true
end

for _, item in ipairs(files) do
    if not download(item.url, item.path) then
        print("")
        print("Installation stopped.")
        print("Check HTTP access and try again.")
        return
    end
end

print("")
print("POBUNK installed successfully!")
print("")
print("Default PIN: 2580")
print("Hardware Center supports: printer, network, drive, speaker.")
print("Service menu is enabled.")
print("")
print("Rebooting...")
sleep(2)
os.reboot()
