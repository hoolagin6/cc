-- Wait a moment for peripherals to stabilize on boot
sleep(0.5)

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
else
    monitor.setTextScale(1)
end
w, h = monitor.getSize()

local channels = {"COZY FIRE", "RETRO BOUNCE", "SYSTEM LOG", "ART SHOW", "CINEMA", "OFF"}
local currentChannel = 1
local running = true

-- Colors
local c_bg = colors.black
local c_acc = colors.red 
local c_txt = colors.white

-- Gallery Settings
local artList = {}
if fs.exists("art") then
    artList = fs.list("art")
end
local currentArtIndex = 1
local artTimer = os.startTimer(3) -- Change art every 3 seconds

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
    if math.random() > 0.8 then
        pcall(function() speaker.playNote("bassdrum", 0.5, 1) end)
    end
end

-- Channel 2: Retro Bounce
local bx, by = 5, 5
local dx, dy = 1, 1
local function drawBounce()
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
    monitor.setTextColor(isAdvanced and colors.lime or colors.white)
    monitor.setCursorPos(2, 4)
    monitor.write("> UPTIME: " .. math.floor(os.clock()))
    monitor.setCursorPos(2, 5)
    monitor.write("> SIGNAL: OK")
    monitor.setCursorPos(2, 6)
    monitor.write("> TEMP: NORM")
end

-- Channel 4: Art Show (Sanjuuni BIMG)
local function drawArtShow()
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(colors.white)
    local cx, cy = math.floor(w/2), math.floor(h/2)
    
    if not fs.exists("art/hool6-face.bimg") then
        monitor.setCursorPos(cx - 10, cy)
        monitor.write("MISSING: hool6-face.bimg")
    else
        monitor.setCursorPos(cx - 10, cy)
        monitor.write("PRESS [SPACE] FOR ART")
        monitor.setCursorPos(cx - 8, cy + 1)
        monitor.write("(2x2 Scale 0.5)")
    end
end

-- Channel 5: Cinema (Sanjuuni)
local function drawCinema()
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(colors.white)
    local cx, cy = math.floor(w/2), math.floor(h/2)
    
    if not fs.exists("video.32vid") then
        monitor.setCursorPos(cx - 8, cy)
        monitor.write("MISSING: video.32vid")
    else
        monitor.setCursorPos(cx - 10, cy)
        monitor.write("PRESS [SPACE] TO PLAY")
        monitor.setCursorPos(cx - 8, cy + 1)
        monitor.write("(2x2 Scale 0.5)")
    end
end

local function playChime()
    local notes = {12, 16, 19, 24}
    for _, note in ipairs(notes) do
        pcall(function() 
            speaker.playNote("harp", 1, note)
            speaker.playNote("pling", 1, note) 
        end)
        sleep(0.15)
    end
end

local function render()
    monitor.setBackgroundColor(c_bg)
    monitor.clear()
    drawHeader()
    drawFooter()
    
    if currentChannel == 1 then
        drawFire()
    elseif currentChannel == 2 then
        drawBounce()
    elseif currentChannel == 3 then
        drawStats()
    elseif currentChannel == 4 then
        drawArtShow()
    elseif currentChannel == 5 then
        drawCinema()
    else
        monitor.clear()
        monitor.setCursorPos(math.floor(w/2)-1, math.floor(h/2))
        monitor.write("OFF")
    end
end

-- Startup
playChime()
term.clear()
term.setCursorPos(1,1)
print("TV CONTROLLER ACTIVE")

local timer = os.startTimer(0.1)
while running do
    local event, p1, p2, p3 = os.pullEvent()
    
    if event == "timer" then
        if p1 == timer then
            render()
            timer = os.startTimer(0.1)
        elseif p1 == artTimer then
            if #artList > 0 then
                currentArtIndex = (currentArtIndex % #artList) + 1
            end
            artTimer = os.startTimer(3)
        end
    elseif event == "monitor_touch" then
        currentChannel = (currentChannel % #channels) + 1
        pcall(function() speaker.playNote("harp", 1, 15) end)
    elseif event == "key" then
        if p1 == keys.q then 
            running = false 
        elseif p1 == keys.space then
            if currentChannel == 4 and fs.exists("art/hool6-face.bimg") then
                local oldTerm = term.redirect(monitor)
                shell.run("bimg-player.lua", "art/hool6-face.bimg")
                term.redirect(oldTerm)
                render()
            elseif currentChannel == 5 and fs.exists("video.32vid") then
                -- Launch Sanjuuni Player
                local oldTerm = term.redirect(monitor)
                shell.run("32vid-player-mini.lua", "video.32vid")
                term.redirect(oldTerm)
                -- Resume TV loop
                render()
            else
                currentChannel = (currentChannel % #channels) + 1
                pcall(function() speaker.playNote("harp", 1, 15) end)
            end
        elseif p1 >= 2 and p1 <= 7 then 
            currentChannel = (p1 - 1)
            pcall(function() speaker.playNote("harp", 1, 15) end)
        end
    end
end

monitor.setBackgroundColor(colors.black)
monitor.clear()
monitor.setCursorPos(1,1)
print("TV Switched Off.")
