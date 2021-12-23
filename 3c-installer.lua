local args = { ... }


local function help ()
  print("Usage: 3c <path> : The path is the complete path to the installation folder to be uploaded")
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
shell.run("cd", path)
shell.run("pastebin", "get", "LVSdkG7J", "3c.lua")
shell.run("pastebin", "get", "wD4NN4Hr", "3c-installer.lua")

-- download lib files
shell.run("cd", "lib")
shell.run("pastebin", "get", "c1mayd0p", "mining.lua")
shell.run("pastebin", "get", "7uGFqgxM", "blockchain.lua")
shell.run("pastebin", "get", "NJ52LATH", "networking.lua")

-- download externals files
shell.run("cd", "externals")
shell.run("pastebin", "get", "eWps9Hvb", "md5.lua")

-- return to root
shell.run("cd", "..")
shell.run("cd", "..")