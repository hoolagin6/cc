local monitor = peripheral.find("monitor")
local speaker = peripheral.find("speaker")

if not monitor then
    print("Error: No monitor found.")
    return
end

-- Detect Hardware Capabilities
local isAdvanced = monitor.isColor()
local w, h

if isAdvanced then
    monitor.setTextScale(0.5)
    print("Advanced Monitor detected: Color & Touch enabled.")
else
    monitor.setTextScale(1)
    print("Standard Monitor detected: B&W only. Use Keyboard to switch.")
end
w, h = monitor.getSize()

local channels = {"COZY FIRE", "RETRO BOUNCE", "SYSTEM LOG", "OFF"}
local currentChannel = 1
local running = true

-- Colors
local c_bg = colors.black
local c_acc = colors.red -- Classic TV brand color
local c_txt = colors.white

local function drawHeader()
    monitor.setBackgroundColor(colors.gray)
    monitor.setTextColor(colors.white)
    monitor.setCursorPos(1, 1)
    monitor.clearLine()
    local time = textutils.formatTime(os.time(), true)
    monitor.write(" [TV] BASEMENT HUB ")
    monitor.setCursorPos(w - #time, 1)
    monitor.write(time)
end

local function drawFooter()
    monitor.setBackgroundColor(colors.gray)
    monitor.setTextColor(colors.lightGray)
    monitor.setCursorPos(1, h)
    monitor.clearLine()
    monitor.write(" CH: " .. currentChannel .. " - " .. channels[currentChannel])
    monitor.setCursorPos(w - 12, h)
    monitor.write("TOUCH TO SW")
end

-- Channel 1: Cozy Fireplace
local fireFrames = {"^", "~", "*", "v"}
local function drawFire()
    monitor.setBackgroundColor(c_bg)
    local cx, cy = math.floor(w/2), math.floor(h/2)
    local fireChars = {"^", "~", "*", "v"}
    for i = 1, 10 do
        local x = math.random(cx-5, cx+5)
        local y = math.random(cy, cy+3)
        monitor.setCursorPos(x, y)
        if isAdvanced then
            monitor.setTextColor(math.random() > 0.5 and colors.orange or colors.red)
        end
        monitor.write(fireChars[math.random(1, #fireChars)])
    end
    -- Crackle sound: Using 'bassdrum' at low pitch for 1.7.3 BTA compatibility
    if math.random() > 0.8 then
        pcall(function() speaker.playNote("bassdrum", 0.5, 1) end)
    end
end

-- Channel 2: Retro Bounce (DVD style)
local bx, by = 5, 5
local dx, dy = 1, 1
local function drawBounce()
    monitor.setBackgroundColor(c_bg)
    monitor.setCursorPos(bx, by)
    monitor.write("   ") -- clear old
    
    bx = bx + dx
    by = by + dy
    
    if bx <= 1 or bx >= w - 3 then dx = -dx end
    if by <= 2 or by >= h - 1 then dy = -dy end
    
    monitor.setCursorPos(bx, by)
    if isAdvanced then monitor.setTextColor(colors.cyan) end
    monitor.write("TV")
end

-- Channel 3: System Stats
local function drawStats()
    monitor.setBackgroundColor(c_bg)
    if isAdvanced then monitor.setTextColor(colors.lime) end
    monitor.setCursorPos(2, 4)
    monitor.write("> UPTIME: " .. math.floor(os.clock()))
    monitor.setCursorPos(2, 5)
    monitor.write("> SIGNAL: OK")
    monitor.setCursorPos(2, 6)
    monitor.write("> TEMP: NORM")
end

local function render()
    if isAdvanced then monitor.setBackgroundColor(c_bg) end
    monitor.clear()
    drawHeader()
    drawFooter()
    
    if currentChannel == 1 then
        drawFire()
    elseif currentChannel == 2 then
        drawBounce()
    elseif currentChannel == 3 then
        drawStats()
    else
        monitor.clear()
        monitor.setCursorPos(math.floor(w/2)-1, math.floor(h/2))
        if isAdvanced then monitor.setTextColor(colors.gray) end
        monitor.write("OFF")
    end
end

-- Main Loop
term.clear()
term.setCursorPos(1,1)
print("TV CONTROLLER ACTIVE")
print("--------------------")
print("1-4 : Change Channel")
print("Space : Next Channel")
print("Q : Quit")

local timer = os.startTimer(0.1)
while running do
    local event, p1, p2, p3 = os.pullEvent()
    
    if event == "timer" and p1 == timer then
        render()
        timer = os.startTimer(0.1)
    elseif event == "monitor_touch" then
        currentChannel = (currentChannel % #channels) + 1
        pcall(function() speaker.playNote("harp", 1, 15) end)
    elseif event == "key" then
        if p1 == keys.q then 
            running = false 
        elseif p1 == keys.space then
            currentChannel = (currentChannel % #channels) + 1
            pcall(function() speaker.playNote("harp", 1, 15) end)
        elseif p1 >= 2 and p1 <= 5 then 
            currentChannel = (p1 - 1)
            pcall(function() speaker.playNote("harp", 1, 15) end)
        end
    end
end

monitor.setBackgroundColor(colors.black)
monitor.clear()
monitor.setCursorPos(1,1)
print("TV Switched Off.")
