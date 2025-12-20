local function getCacheBuster()
    if os.epoch then return os.epoch("utc") end
    return math.random(1, 1000000)
end

local cb = getCacheBuster()
local BASE_URL = "https://raw.githubusercontent.com/hoolagin6/cc/main/"

local function download(url, path)
    local resp = http.get(url .. "?cb=" .. cb)
    if resp then
        local f = fs.open(path, "w")
        f.write(resp.readAll())
        f.close()
        resp.close()
        return true
    end
    return false
end

print("Syncing Sanjuuni Player...")
if not fs.exists("bimg-player.lua") then
    print(" Downloading player...")
    download("https://raw.githubusercontent.com/MCJack123/sanjuuni/master/bimg-player.lua", "bimg-player.lua")
end

print("Updating Program...")
if download(BASE_URL .. "program.lua", "program.lua") then
    print("Update successful.")
else
    print("Running local version...")
end

if fs.exists("program.lua") then
    shell.run("program.lua")
else
    print("Error: program.lua not found!")
end
