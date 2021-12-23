local args = { ... }


local function help ()
  print("Usage: 3c <path> : The path is the path to the installation folder to be uploaded")
end

if #args ~= 1 then
  help()
  error()
end

local path = args[1]
-- create directories
shell.run("mkdir", path)
shell.run("mkdir", path .. "/lib")
shell.run("mkdir", path .. "/lib/externals")

-- download root files
shell.run("pastebin", "get", "LVSdkG7J", "3c.lua")
shell.run("pastebin", "get", "LVSdkG7J", "3c-installer.lua")
shell.run("pastebin", "get", "", "")
shell.run("pastebin", "get", "", "")
shell.run("pastebin", "get", "", "")