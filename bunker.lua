-- POBUNK CONTROL v1.1.0
-- CC:Tweaked / Minecraft 1.16.5

local cfg = require("config")
local monitor = peripheral.find("monitor")
local modem = peripheral.find("modem")
local target = monitor or term
local log = {}
local state = {
    locked = cfg.startup_door_locked,
    lights = cfg.startup_lights,
    ventilation = cfg.startup_ventilation,
    alarm = false,
    lockdown = false,
    authenticated = false,
    attempts = 0,
    last_event = "System boot"
}

local function now() return os.date("%H:%M:%S") end
local function addLog(text)
    table.insert(log, 1, now() .. "  " .. text)
    while #log > cfg.max_log_entries do table.remove(log) end
    state.last_event = text
end
local function setOutput(name, value)
    local side = cfg.outputs[name]
    if side and side ~= "none" then redstone.setOutput(side, value) end
end
local function setDoor(v,s) state.locked=v; setOutput("door",v); addLog((v and "DOOR LOCKED" or "DOOR UNLOCKED")..(s and " / "..s or "")) end
local function setLights(v,s) state.lights=v; setOutput("lights",v); addLog((v and "LIGHTS ON" or "LIGHTS OFF")..(s and " / "..s or "")) end
local function setVent(v,s) state.ventilation=v; setOutput("ventilation",v); addLog((v and "VENTILATION ON" or "VENTILATION OFF")..(s and " / "..s or "")) end
local function setAlarm(v,s) state.alarm=v; setOutput("alarm",v); addLog((v and "ALARM ACTIVATED" or "ALARM CLEARED")..(s and " / "..s or "")) end
local function lockdown(s)
    state.lockdown=true
    setDoor(true,s or "LOCKDOWN")
    setAlarm(true,s or "LOCKDOWN")
    setLights(true,s or "LOCKDOWN")
    setVent(true,s or "LOCKDOWN")
    addLog("!!! LOCKDOWN ACTIVE !!!")
end
local function clearLockdown() state.lockdown=false; setAlarm(false,"ADMIN"); addLog("LOCKDOWN CLEARED") end
local function readInput(name)
    local side=cfg.inputs[name]
    return side and side~="none" and redstone.getInput(side) or false
end
local function applyStartup()
    setOutput("door",state.locked)
    setOutput("lights",state.lights)
    setOutput("ventilation",state.ventilation)
    setOutput("alarm",state.alarm)
    addLog("System initialized")
end

local function header(t,w)
    t.setCursorPos(1,1)
    t.setBackgroundColor(colors.blue)
    t.setTextColor(colors.white)
    t.clearLine()
    t.write(("  "..cfg.title.." v"..cfg.version):sub(1,w))
end
local function fillButton(t,x,y,w,h,label,bg,fg)
    local tw,th=t.getSize()
    if x>tw or y>th then return end
    w=math.max(1,math.min(w,tw-x+1)); h=math.max(1,math.min(h,th-y+1))
    t.setBackgroundColor(bg); t.setTextColor(fg or colors.white)
    for yy=y,y+h-1 do t.setCursorPos(x,yy); t.write(string.rep(" ",w)) end
    local tx=x+math.max(0,math.floor((w-#label)/2))
    local ty=y+math.floor(h/2)
    t.setCursorPos(tx,ty); t.write(label:sub(1,w))
end
local function center(t,y,text,w)
    t.setCursorPos(math.max(1,math.floor((w-#text)/2)+1),y); t.write(text)
end

local mainButtons={
    {id="door",x=2,y=5,w=18,h=3,label="DOOR"},
    {id="lights",x=21,y=5,w=18,h=3,label="LIGHTS"},
    {id="vent",x=2,y=9,w=18,h=3,label="VENTILATION"},
    {id="alarm",x=21,y=9,w=18,h=3,label="ALARM"},
    {id="lockdown",x=2,y=13,w=37,h=3,label="EMERGENCY LOCKDOWN"},
    {id="clear",x=2,y=17,w=18,h=2,label="CLEAR ALARM"},
    {id="logs",x=21,y=17,w=18,h=2,label="EVENT LOG"}
}

local function drawStatus(t,w)
    t.setBackgroundColor(colors.black); t.setTextColor(colors.white)
    t.setCursorPos(1,2); t.write(string.rep(" ",w)); t.setCursorPos(2,2); t.write("SECURITY: ")
    t.setTextColor(state.lockdown and colors.red or colors.lime)
    t.write(state.lockdown and "LOCKDOWN" or "NORMAL")
    t.setTextColor(colors.white)
    t.setCursorPos(2,3); t.write("Door: "..(state.locked and "LOCKED" or "UNLOCKED").."   Lights: "..(state.lights and "ON" or "OFF"))
    t.setCursorPos(2,4); t.write("Vent: "..(state.ventilation and "ON" or "OFF").."      Alarm: "..(state.alarm and "ON" or "OFF"))
end
local function drawMain(t)
    local w,h=t.getSize(); t.setBackgroundColor(colors.black); t.clear(); header(t,w); drawStatus(t,w)
    for _,b in ipairs(mainButtons) do
        local active=(b.id=="door" and state.locked) or (b.id=="lights" and state.lights) or (b.id=="vent" and state.ventilation) or (b.id=="alarm" and state.alarm)
        local c=active and colors.green or colors.gray
        if b.id=="lockdown" then c=colors.red elseif b.id=="clear" then c=colors.orange end
        fillButton(t,b.x,b.y,b.w,b.h,b.label,c)
    end
    if h>=22 then
        t.setTextColor(colors.lightGray); t.setCursorPos(2,22)
        t.write("Motion:"..(readInput("motion") and "ACTIVE" or "clear").."  Emergency:"..(readInput("emergency") and "PRESSED" or "clear"))
    end
    if h>=23 then t.setCursorPos(2,23); t.write("Last: "..state.last_event:sub(1,math.max(1,w-7))) end
end

local function drawLogs(t)
    local w,h=t.getSize(); t.setBackgroundColor(colors.black); t.setTextColor(colors.white); t.clear(); header(t,w)
    t.setCursorPos(2,3); t.write("EVENT LOG (newest first)")
    local y=4
    for i=1,math.min(#log,h-6) do
        t.setCursorPos(2,y); t.setTextColor(i==1 and colors.yellow or colors.lightGray)
        t.write(log[i]:sub(1,math.max(1,w-2))); y=y+1
    end
    fillButton(t,2,h-2,18,2,"BACK",colors.gray)
end

-- Touchscreen PIN keypad
local pin=""
local function drawPin(t)
    local w,h=t.getSize(); t.setBackgroundColor(colors.black); t.setTextColor(colors.white); t.clear(); header(t,w)
    center(t,3,"BUNKER SECURITY",w)
    center(t,4,"ENTER ACCESS PIN",w)
    center(t,6,string.rep("*",#pin),w)

    local keyW=7; local keyH=2; local gap=1
    local totalW=keyW*3+gap*2
    local sx=math.max(1,math.floor((w-totalW)/2)+1)
    local sy=8
    local nums={{"1","2","3"},{"4","5","6"},{"7","8","9"},{"CLR","0","ENTER"}}
    for r,row in ipairs(nums) do
        for c,label in ipairs(row) do
            local x=sx+(c-1)*(keyW+gap)
            local y=sy+(r-1)*(keyH+gap)
            local col=colors.gray
            if label=="ENTER" then col=colors.green elseif label=="CLR" then col=colors.orange end
            fillButton(t,x,y,keyW,keyH,label,col)
        end
    end
    if h>=18 then center(t,18,"Keyboard also supported",w) end
end

local function pinButtonAt(x,y,t)
    local w=t.getSize(); local keyW=7; local keyH=2; local gap=1
    local totalW=keyW*3+gap*2; local sx=math.max(1,math.floor((w-totalW)/2)+1); local sy=8
    local nums={{"1","2","3"},{"4","5","6"},{"7","8","9"},{"CLR","0","ENTER"}}
    for r,row in ipairs(nums) do
        for c,label in ipairs(row) do
            local bx=sx+(c-1)*(keyW+gap); local by=sy+(r-1)*(keyH+gap)
            if x>=bx and x<bx+keyW and y>=by and y<by+keyH then return label end
        end
    end
end

local function tryPin()
    if pin==cfg.pin then
        state.authenticated=true
        addLog("Local operator authenticated")
        pin=""
        return true
    end
    state.attempts=state.attempts+1
    addLog("Invalid PIN attempt")
    pin=""
    if state.attempts>=cfg.max_attempts then lockdown("SECURITY") end
    return false
end

local function doAction(id,source)
    if state.lockdown and id~="clear" then return end
    if id=="door" then setDoor(not state.locked,source)
    elseif id=="lights" then setLights(not state.lights,source)
    elseif id=="vent" then setVent(not state.ventilation,source)
    elseif id=="alarm" then setAlarm(not state.alarm,source)
    elseif id=="lockdown" then lockdown(source)
    elseif id=="clear" then clearLockdown() end
end
local function buttonAt(x,y)
    for _,b in ipairs(mainButtons) do if x>=b.x and x<b.x+b.w and y>=b.y and y<b.y+b.h then return b end end
end
local function remoteCommand(msg)
    if type(msg)~="table" or msg.password~=cfg.remote_password then return {ok=false,error="AUTH"} end
    if msg.action=="status" then return {ok=true,locked=state.locked,lights=state.lights,ventilation=state.ventilation,alarm=state.alarm,lockdown=state.lockdown} end
    if msg.action=="lock" then setDoor(true,"REMOTE")
    elseif msg.action=="unlock" then if not state.lockdown then setDoor(false,"REMOTE") end
    elseif msg.action=="lights" then setLights(msg.value~=false,"REMOTE")
    elseif msg.action=="ventilation" then setVent(msg.value~=false,"REMOTE")
    elseif msg.action=="alarm" then setAlarm(msg.value~=false,"REMOTE")
    elseif msg.action=="lockdown" then lockdown("REMOTE")
    elseif msg.action=="clear" then clearLockdown()
    else return {ok=false,error="UNKNOWN_ACTION"} end
    return {ok=true}
end

applyStartup()
if modem and cfg.remote_enabled then modem.open(cfg.remote_channel) end
term.setBackgroundColor(colors.black); term.setTextColor(colors.white); term.clear()
if monitor then monitor.setTextScale(1) end

local screen="pin"
drawPin(target)

local function handleKey(key)
    if screen=="pin" then
        if key==keys.backspace then pin=pin:sub(1,-2); drawPin(target)
        elseif key==keys.enter then tryPin(); drawPin(target)
        elseif key==keys.q then end
    else
        if key==keys.q then os.shutdown() end
    end
end
local function handleChar(ch)
    if screen=="pin" and ch and ch:match("%d") and #pin<12 then pin=pin..ch; drawPin(target) end
end
local function handleTouch(x,y)
    if screen=="pin" then
        local label=pinButtonAt(x,y,target)
        if label then
            if label=="CLR" then pin=""
            elseif label=="ENTER" then if tryPin() then screen="main" end
            elseif label:match("^%d$") and #pin<12 then pin=pin..label end
            drawPin(target)
            if screen=="main" then drawMain(target) end
        end
    elseif screen=="main" then
        local b=buttonAt(x,y)
        if b then
            if b.id=="logs" then screen="logs"; drawLogs(target)
            else doAction(b.id,"LOCAL"); drawMain(target) end
        end
    elseif screen=="logs" then
        local _,h=target.getSize()
        if y>=h-2 then screen="main"; drawMain(target) end
    end
end

while true do
    local ev={os.pullEvent()}; local name=ev[1]
    if name=="key" then handleKey(ev[2])
    elseif name=="char" then handleChar(ev[2])
    elseif name=="monitor_touch" and monitor and ev[2]==peripheral.getName(monitor) and state.authenticated then handleTouch(ev[3],ev[4])
    elseif name=="monitor_touch" and monitor and ev[2]==peripheral.getName(monitor) and not state.authenticated then handleTouch(ev[3],ev[4])
    elseif name=="mouse_click" and target==term then handleTouch(ev[3],ev[4])
    elseif name=="redstone" then
        local emergency=readInput("emergency"); local motion=readInput("motion")
        if emergency and cfg.lockdown_on_emergency and not state.lockdown then lockdown("EMERGENCY INPUT")
        elseif motion and cfg.auto_alarm_on_motion and not state.alarm and not state.lockdown then setAlarm(true,"MOTION SENSOR") end
    elseif name=="modem_message" and modem and ev[3]==cfg.remote_channel then
        local replyChannel=ev[4]; local response=remoteCommand(ev[5])
        if replyChannel and replyChannel>0 then modem.transmit(replyChannel,cfg.remote_channel,response) end
    end
    if screen=="main" and state.authenticated then drawMain(target) end
end