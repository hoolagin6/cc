local monitor = peripheral.find("monitor")
local speaker = peripheral.find("speaker")

if not monitor then
    print("Error: No monitor found attached to the computer.")
    return
end

if not speaker then
    print("Error: No speaker found attached to the computer.")
    return
end

-- Configuration
local bgColor = colors.black
local textColor = colors.cyan
local accentColor = colors.yellow

-- Setup monitor
monitor.setTextScale(1)
monitor.setBackgroundColor(bgColor)
monitor.setTextColor(textColor)
monitor.clear()

local w, h = monitor.getSize()

local function centerText(text, y, color)
    if color then monitor.setTextColor(color) end
    local x = math.floor((w - #text) / 2) + 1
    monitor.setCursorPos(x, y)
    monitor.write(text)
end

-- UI Layout
centerText("====================", 2, accentColor)
centerText("CC:TWEAKED SYSTEM", 3, textColor)
centerText("====================", 4, accentColor)

centerText("STATUS: ONLINE", 6, colors.lime)
centerText("AUDIO: READY", 7, colors.lime)

centerText("Press Any Key", h - 1, colors.lightGray)

-- Play Startup Chime (C-E-G-C Arpeggio)
-- Note: 'chime' is supported in modern CC:T. If it fails, we fall back to 'harp'
local function playChime()
    local instrument = "chime"
    -- Defensive check: if chime isn't supported, Minecraft usually defaults or errors.
    -- We'll try to use harp if chime fails or if you want a classic sound.
    pcall(function()
        speaker.playNote(instrument, 1, 12) -- Middle C
        sleep(0.15)
        speaker.playNote(instrument, 1, 16) -- E
        sleep(0.15)
        speaker.playNote(instrument, 1, 19) -- G
        sleep(0.15)
        speaker.playNote(instrument, 1, 24) -- High C
    end)
end

playChime()

print("Program running on monitor.")
print("Playing chime...")

-- Wait for user to interact
while true do
    local event, p1, p2, p3 = os.pullEvent()
    
    if event == "key" then
        -- p1 is the key code
        centerText("ALERT: KEY " .. tostring(p1) .. " PRESSED", 9, colors.orange)
        speaker.playNote("bit", 1, 20)
        sleep(0.5)
        centerText("                        ", 9) -- Clear alert
        
    elseif event == "char" then
        -- p1 is the character typed
        centerText("TYPED: " .. p1, 10, colors.yellow)
        sleep(0.5)
        centerText("              ", 10)

    elseif event == "monitor_touch" then
        -- p1: side, p2: x, p3: y
        centerText("SCREEN TOUCHED AT " .. p2 .. "," .. p3, 9, colors.pink)
        speaker.playNote("bell", 1, 24)
        sleep(0.5)
        centerText("                        ", 9)
    end
end
