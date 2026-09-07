-- POBUNK CONTROL v1.0.0
-- CC:Tweaked / Minecraft 1.16.5

local cfg = require("config")

local monitor = peripheral.find("monitor")
local modem = peripheral.find("modem")
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

local function now()
    return os.date("%H:%M:%S")
end

local function addLog(text)
    local line = now() .. "  " .. text
    table.insert(log, 1, line)
    while #log > cfg.max_log_entries do table.remove(log) end
    state.last_event = text
end

local function setOutput(name, value)
    local side = cfg.outputs[name]
    if not side or side == "none" then return end
    redstone.setOutput(side, value)
end

local function setDoor(locked, source)
    state.locked = locked
    setOutput("door", locked)
    addLog((locked and "DOOR LOCKED" or "DOOR UNLOCKED") .. (source and " / " .. source or ""))
end

local function setLights(value, source)
    state.lights = value
    setOutput("lights", value)
    addLog((value and "LIGHTS ON" or "LIGHTS OFF") .. (source and " / " .. source or ""))
end

local function setVent(value, source)
    state.ventilation = value
    setOutput("ventilation", value)
    addLog((value and "VENTILATION ON" or "VENTILATION OFF") .. (source and " / " .. source or ""))
end

local function setAlarm(value, source)
    state.alarm = value
    setOutput("alarm", value)
    addLog((value and "ALARM ACTIVATED" or "ALARM CLEARED") .. (source and " / " .. source or ""))
end

local function lockdown(source)
    state.lockdown = true
    setDoor(true, source or "LOCKDOWN")
    setAlarm(true, source or "LOCKDOWN")
    setLights(true, source or "LOCKDOWN")
    setVent(true, source or "LOCKDOWN")
    addLog("!!! LOCKDOWN ACTIVE !!!")
end

local function clearLockdown()
    state.lockdown = false
    setAlarm(false, "ADMIN")
    addLog("LOCKDOWN CLEARED")
end

local function readInput(name)
    local side = cfg.inputs[name]
    if not side or side == "none" then return false end
    return redstone.getInput(side)
end

local function applyStartup()
    setOutput("door", state.locked)
    setOutput("lights", state.lights)
    setOutput("ventilation", state.ventilation)
    setOutput("alarm", state.alarm)
    addLog("System initialized")
end

local function termWrite(x, y, text)
    term.setCursorPos(x, y)
    term.clearLine()
    term.write(text)
end

local function drawHeader(t, w)
    t.setCursorPos(1, 1)
    t.setBackgroundColor(colors.blue)
    t.setTextColor(colors.white)
    t.clearLine()
    local title = "  " .. cfg.title .. " v" .. cfg.version
    t.write(title:sub(1, w))
end

local function centered(t, y, text, w)
    local x = math.max(1, math.floor((w - #text) / 2) + 1)
    t.setCursorPos(x, y)
    t.write(text)
end

local function button(t, x, y, w, h, label, color, textColor)
    t.setBackgroundColor(color)
    t.setTextColor(textColor or colors.white)
    for yy = y, y + h - 1 do
        t.setCursorPos(x, yy)
        t.write(string.rep(" ", w))
    end
    centeredAt = nil
    local tx = x + math.max(0, math.floor((w - #label) / 2))
    local ty = y + math.floor(h / 2)
    t.setCursorPos(tx, ty)
    t.write(label)
end

local buttons = {
    {id="door", x=2,  y=5, w=18, h=3, label="DOOR", mode="toggle"},
    {id="lights", x=21, y=5, w=18, h=3, label="LIGHTS", mode="toggle"},
    {id="vent", x=2, y=9, w=18, h=3, label="VENTILATION", mode="toggle"},
    {id="alarm", x=21, y=9, w=18, h=3, label="ALARM", mode="toggle"},
    {id="lockdown", x=2, y=13, w=37, h=3, label="EMERGENCY LOCKDOWN", mode="lockdown"},
    {id="clear", x=2, y=17, w=18, h=3, label="CLEAR ALARM", mode="clear"},
    {id="logs", x=21, y=17, w=18, h=3, label="EVENT LOG", mode="logs"}
}

local function drawStatus(t, w)
    t.setTextColor(colors.white)
    t.setBackgroundColor(colors.black)
    termWrite = nil
    t.setCursorPos(1, 2)
    t.write(string.rep(" ", w))
    t.setCursorPos(2, 2)
    t.write("SECURITY: ")
    if state.lockdown then
        t.setTextColor(colors.red)
        t.write("LOCKDOWN")
    else
        t.setTextColor(colors.lime)
        t.write("NORMAL")
    end
    t.setTextColor(colors.white)
    t.setCursorPos(2, 3)
    t.write("Door: " .. (state.locked and "LOCKED" or "UNLOCKED") .. "   Lights: " .. (state.lights and "ON" or "OFF"))
    t.setCursorPos(2, 4)
    t.write("Vent: " .. (state.ventilation and "ON" or "OFF") .. "      Alarm: " .. (state.alarm and "ON" or "OFF"))
end

local function drawMain(t)
    local w, h = t.getSize()
    t.setBackgroundColor(colors.black)
    t.setTextColor(colors.white)
    t.clear()
    drawHeader(t, w)
    drawStatus(t, w)
    for _, b in ipairs(buttons) do
        local active = false
        if b.id == "door" then active = state.locked
        elseif b.id == "lights" then active = state.lights
        elseif b.id == "vent" then active = state.ventilation
        elseif b.id == "alarm" then active = state.alarm end
        local c = active and colors.green or colors.gray
        if b.mode == "lockdown" then c = colors.red
        elseif b.mode == "clear" then c = colors.orange end
        button(t, b.x, b.y, math.min(b.w, w - b.x + 1), math.min(b.h, h - b.y + 1), b.label, c)
    end
    t.setTextColor(colors.lightGray)
    t.setCursorPos(2, math.min(h, 22))
    t.write((cfg.inputs.motion ~= "none" and "Motion:" .. (readInput("motion") and "ACTIVE" or "clear") or "Motion:N/A") ..
        "  Emergency:" .. (readInput("emergency") and "PRESSED" or "clear"))
    t.setCursorPos(2, math.min(h, 23))
    t.write("Last: " .. state.last_event:sub(1, math.max(1, w - 7)))
end

local function drawLogs(t)
    local w, h = t.getSize()
    t.setBackgroundColor(colors.black)
    t.setTextColor(colors.white)
    t.clear()
    drawHeader(t, w)
    t.setCursorPos(2, 3)
    t.write("EVENT LOG (newest first)")
    local y = 4
    for i = 1, math.min(#log, h - 6) do
        t.setCursorPos(2, y)
        t.setTextColor(i == 1 and colors.yellow or colors.lightGray)
        t.write(log[i]:sub(1, math.max(1, w - 2)))
        y = y + 1
    end
    button(t, 2, h - 2, math.min(18, w - 2), 2, "BACK", colors.gray)
end

local function drawPin(t, input)
    local w = t.getSize()
    t.setBackgroundColor(colors.black)
    t.setTextColor(colors.white)
    t.clear()
    drawHeader(t, w)
    centered(t, 5, "SECURITY ACCESS", w)
    centered(t, 7, "Enter PIN:", w)
    centered(t, 9, string.rep("*", #input), w)
    centered(t, 11, "ENTER = confirm   BACKSPACE = erase", w)
    centered(t, 12, "CTRL+T = terminal mode", w)
end

local function doAction(id, source)
    if state.lockdown and id ~= "clear" then return end
    if id == "door" then setDoor(not state.locked, source)
    elseif id == "lights" then setLights(not state.lights, source)
    elseif id == "vent" then setVent(not state.ventilation, source)
    elseif id == "alarm" then setAlarm(not state.alarm, source)
    elseif id == "lockdown" then lockdown(source)
    elseif id == "clear" then clearLockdown()
    end
end

local function buttonAt(x, y)
    for _, b in ipairs(buttons) do
        if x >= b.x and x < b.x + b.w and y >= b.y and y < b.y + b.h then
            return b
        end
    end
    return nil
end

local function remoteCommand(msg)
    if type(msg) ~= "table" or msg.password ~= cfg.remote_password then return {ok=false, error="AUTH"} end
    if msg.action == "status" then
        return {ok=true, locked=state.locked, lights=state.lights, ventilation=state.ventilation, alarm=state.alarm, lockdown=state.lockdown}
    end
    local map = {lock=true, unlock=true, lights=true, ventilation=true, alarm=true, lockdown=true, clear=true}
    if not map[msg.action] then return {ok=false, error="UNKNOWN_ACTION"} end
    if msg.action == "lock" then setDoor(true, "REMOTE")
    elseif msg.action == "unlock" then if not state.lockdown then setDoor(false, "REMOTE") end
    elseif msg.action == "lights" then setLights(msg.value ~= false, "REMOTE")
    elseif msg.action == "ventilation" then setVent(msg.value ~= false, "REMOTE")
    elseif msg.action == "alarm" then setAlarm(msg.value ~= false, "REMOTE")
    elseif msg.action == "lockdown" then lockdown("REMOTE")
    elseif msg.action == "clear" then clearLockdown() end
    return {ok=true}
end

local function remoteLoop()
    if not modem or not cfg.remote_enabled then return end
    modem.open(cfg.remote_channel)
end

applyStartup()
remoteLoop()
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()

local target = monitor or term
if monitor then monitor.setTextScale(1) end

local pin = ""
local screen = "pin"
local running = true

drawPin(target, pin)

local function handleKey(key)
    if screen ~= "pin" then
        if key == keys.q then running = false end
        return
    end
    if key == keys.backspace then
        pin = pin:sub(1, -2)
    elseif key == keys.enter then
        if pin == cfg.pin then
            state.authenticated = true
            screen = "main"
            addLog("Local operator authenticated")
        else
            state.attempts = state.attempts + 1
            addLog("Invalid PIN attempt")
            if state.attempts >= cfg.max_attempts then lockdown("SECURITY") end
        end
        pin = ""
    end
    drawPin(target, pin)
end

local function handleTouch(x, y)
    if screen == "main" then
        local b = buttonAt(x, y)
        if b then
            if b.mode == "logs" then screen = "logs"
            else doAction(b.id, "LOCAL") end
            if screen == "main" then drawMain(target) else drawLogs(target) end
        end
    elseif screen == "logs" then
        local _, h = target.getSize()
        if y >= h - 2 then screen = "main"; drawMain(target) end
    end
end

while running do
    if screen == "main" then drawMain(target) end
    local ev = table.pack(os.pullEvent())
    local name = ev[1]

    if name == "key" then
        handleKey(ev[2])
    elseif name == "monitor_touch" and ev[2] == peripheral.getName(monitor) then
        if state.authenticated then handleTouch(ev[3], ev[4]) end
    elseif name == "mouse_click" and target == term then
        if state.authenticated then handleTouch(ev[3], ev[4]) end
    elseif name == "redstone" then
        local emergency = readInput("emergency")
        local motion = readInput("motion")
        if emergency and cfg.lockdown_on_emergency and not state.lockdown then
            lockdown("EMERGENCY INPUT")
        elseif motion and cfg.auto_alarm_on_motion and not state.alarm and not state.lockdown then
            setAlarm(true, "MOTION SENSOR")
        end
    elseif name == "modem_message" and modem and ev[5] == cfg.remote_channel then
        local response = remoteCommand(ev[4])
        modem.transmit(ev[4] and ev[3] or cfg.remote_channel, cfg.remote_channel, response)
    end
end

if modem then modem.close(cfg.remote_channel) end
setAlarm(false, "SHUTDOWN")
