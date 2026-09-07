-- POBUNK DIAGNOSTICS v1.0
-- CC:Tweaked / Minecraft 1.16.5
-- Optional companion utility. Does not change bunker outputs.

local monitor = peripheral.find("monitor")
local target = monitor or term
if monitor then monitor.setTextScale(1) end

local function draw()
    local w,h = target.getSize()
    target.setBackgroundColor(colors.black)
    target.setTextColor(colors.white)
    target.clear()

    target.setBackgroundColor(colors.blue)
    target.setCursorPos(1,1)
    target.clearLine()
    target.write("  POBUNK SYSTEM DIAGNOSTICS")

    target.setBackgroundColor(colors.black)
    target.setTextColor(colors.white)
    local y = 3

    local function line(label, value)
        if y <= h then
            target.setCursorPos(2,y)
            target.setTextColor(colors.lightGray)
            target.write(label .. ": ")
            target.setTextColor(colors.white)
            target.write(tostring(value):sub(1, math.max(1, w-#label-4)))
            y = y + 1
        end
    end

    local sides = {"top","bottom","left","right","front","back"}
    line("Computer ID", os.getComputerID())
    line("Computer label", os.getComputerLabel() or "none")
    line("Time", os.date("%H:%M:%S"))
    line("Date", os.date("%Y-%m-%d"))
    line("Free memory", tostring(math.floor(collectgarbage("count"))) .. " KB")
    line("Monitor", monitor and peripheral.getName(monitor) or "none")

    y = y + 1
    if y <= h then
        target.setCursorPos(2,y)
        target.setTextColor(colors.yellow)
        target.write("REDSTONE INPUTS / OUTPUTS")
        y = y + 1
    end

    for _,side in ipairs(sides) do
        if y <= h then
            local input = redstone.getInput(side)
            local output = redstone.getOutput(side)
            target.setCursorPos(2,y)
            target.setTextColor(input and colors.lime or colors.lightGray)
            target.write(side .. "  IN=" .. (input and "ON " or "OFF") .. " OUT=" .. (output and "ON" or "OFF"))
            y = y + 1
        end
    end

    y = y + 1
    if y <= h then
        target.setCursorPos(2,y)
        target.setTextColor(colors.yellow)
        target.write("CONNECTED PERIPHERALS")
        y = y + 1
    end

    for _,name in ipairs(peripheral.getNames()) do
        if y <= h then
            target.setCursorPos(2,y)
            target.setTextColor(colors.white)
            local ptype = peripheral.getType(name) or "unknown"
            target.write((name .. "  [" .. ptype .. "]"):sub(1, math.max(1,w-1)))
            y = y + 1
        end
    end

    if h >= 2 then
        target.setCursorPos(1,h)
        target.setTextColor(colors.lightGray)
        target.write("R=refresh  Q=exit")
    end
end

draw()
while true do
    local ev = {os.pullEvent()}
    if ev[1] == "key" and ev[2] == keys.q then
        break
    elseif ev[1] == "key" and ev[2] == keys.r then
        draw()
    elseif ev[1] == "timer" then
        draw()
    end
    os.startTimer(1)
end
