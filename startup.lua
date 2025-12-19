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

print("Syncing Art Gallery...")
if not fs.exists("art") then fs.makeDir("art") end

-- Get the list of art files
if download(BASE_URL .. "art/list.txt", "art/list.txt") then
    local f = fs.open("art/list.txt", "r")
    local line = f.readLine()
    while line do
        print(" Downloading: " .. line)
        download(BASE_URL .. "art/" .. line, "art/" .. line)
        line = f.readLine()
    end
    f.close()
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
