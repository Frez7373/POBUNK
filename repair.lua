-- OSBUNK emergency repair
local URL='https://raw.githubusercontent.com/Frez7373/POBUNK/main/osbunk_fixed.lua'
term.clear();term.setCursorPos(1,1);print('OSBUNK REPAIR 2.0.2');print('Downloading fixed core...')
local r=http.get(URL)
if not r then error('HTTP API unavailable') end
local data=r.readAll();r.close()
data=data:gsub("setAlarm%(false%)","alarm(false)")
local f=fs.open('/osbunk.lua','w');f.write(data);f.close()
print('Core repaired.')
print('Rebooting...');sleep(1);os.reboot()
