-- script: check_res
local mon = peripheral.find("monitor")

if not mon then
    error("No monitor attached!")
end

-- Set to smallest text size for maximum resolution
mon.setTextScale(0.5)

local w, h = mon.getSize()

term.clear()
term.setCursorPos(1,1)
print("--- Monitor Stats ---")
print("Width:  " .. w)
print("Height: " .. h)
print("---------------------")
print("Put these numbers into")
print("the Python script!")