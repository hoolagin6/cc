-- usage: stream_play
local args = { ... }

-- 1. Setup Display
local mon = peripheral.find("monitor")
local monSide = mon and peripheral.getName(mon)
local target = mon or term
local useMonitor = mon ~= nil

local function setupDisplay()
    if useMonitor then
        mon.setTextScale(0.5)
        mon.clear()
    else
        term.clear()
        term.setCursorPos(1,1)
    end
end

setupDisplay()

-- 2. Get Video Files
local function getVidFiles()
    local files = fs.list(".")
    local vids = {}
    for _, f in ipairs(files) do
        if f:match("%.vid$") then
            table.insert(vids, f)
        end
    end
    table.sort(vids)
    return vids
end

local vids = getVidFiles()
if #vids == 0 then error("No .vid files found") end

local currentVidIndex = 1

-- 3. Playback Logic
local function playVideo(filename)
    if not fs.exists(filename) then return false end
    local file = fs.open(filename, "r")
    
    -- Read Header (Width, Height)
    local header = file.readLine()
    if not header then file.close() return false end
    local w_str, h_str = header:match("([^,]+),([^,]+)")
    local vid_w, vid_h = tonumber(w_str), tonumber(h_str)
    
    local emptyLine = string.rep(" ", vid_w)
    local textColors = string.rep("0", vid_w)

    term.setCursorPos(1, 1)
    term.clearLine()
    print("Playing: " .. filename .. (useMonitor and " (Monitor)" or " (Terminal)"))
    print("Press 'Q' to quit, 'M' to toggle display")

    while true do
        local canBuffer = (target.setVisible ~= nil)
        if canBuffer then target.setVisible(false) end
        
        for y = 1, vid_h do
            local lineData = file.readLine()
            if not lineData then 
                file.close() 
                return true -- Finished file normally
            end
            target.setCursorPos(1, y)
            target.blit(emptyLine, textColors, lineData)
        end
        
        if canBuffer then target.setVisible(true) end
        
        -- Event handling & Speed control
        local timer = os.startTimer(0.05)
        while true do
            local e, p1, p2 = os.pullEvent()
            if e == "timer" and p1 == timer then
                break -- Go to next frame
            elseif e == "char" and (p1 == "q" or p1 == "Q") then
                file.close()
                return false -- Exit program
            elseif e == "monitor_touch" and useMonitor and p1 == monSide then
                file.close()
                return false -- Exit program
            elseif e == "char" and (p1 == "m" or p1 == "M") then
                if mon then
                    -- Toggle logic
                    useMonitor = not useMonitor
                    if useMonitor then
                        term.clear()
                        target = mon
                    else
                        mon.clear()
                        target = term
                    end
                    setupDisplay()
                    -- Rewind file to start of frame data for cleaner transition
                    -- (Simpler to just return and restart this file in main loop)
                    file.close()
                    return "switch"
                end
            end
        end
    end
end

-- 4. Main Loop
while true do
    local result = playVideo(vids[currentVidIndex])
    if result == false then 
        break 
    elseif result == true then
        currentVidIndex = currentVidIndex + 1
        if currentVidIndex > #vids then
            currentVidIndex = 1
        end
    elseif result == "switch" then
        -- Refresh the same video on the new display
    end
end

-- Cleanup
if mon then
    mon.setTextScale(1)
    mon.clear()
end
term.clear()
term.setCursorPos(1,1)
print("Stopped.")