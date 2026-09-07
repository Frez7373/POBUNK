print('OSBUNK syntax fix installer')
local u='https://raw.githubusercontent.com/Frez7373/POBUNK/main/osbunk.lua'
local r=http.get(u); if not r then error('HTTP unavailable') end
local d=r.readAll(); r.close(); local f=fs.open('/osbunk.lua','w'); f.write(d); f.close(); print('osbunk.lua refreshed'); os.reboot()
