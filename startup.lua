local GITHUB_URL = "https://raw.githubusercontent.com/hoolagin6/cc/main/main.lua"
local PROGRAM_NAME = "main.lua"

print("Checking for updates...")

local response = http.get(GITHUB_URL)
if response then
    print("Update found! Downloading...")
    local file = fs.open(PROGRAM_NAME, "w")
    file.write(response.readAll())
    file.close()
    response.close()
    print("Update successful.")
else
    print("Could not reach GitHub. Running local version...")
end

if fs.exists(PROGRAM_NAME) then
    shell.run(PROGRAM_NAME)
else
    print("Error: Program file not found!")
end
