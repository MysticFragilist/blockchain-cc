local blockchain = require './lib/blockchain'
local networking = require './lib/networking'
local mining = require './lib/mining'

--------------------------------------------------------------------------------
-- MAIN program
--------------------------------------------------------------------------------
local args = { ... }

local function defineDirectory ()
  if not fs.exists(dir) then
    fs.makeDir(dir)
  end

end

local function wait_for_q()
  repeat
      local _, key = os.pullEvent("key")
  until key == keys.q
  print("Q was pressed! Exiting node run...")
end

local function help ()
  print("Usage: 3c <param>")
  print("Possible parameter to use:")
  print("  -i, --init: initialize the blockchain")
  print("  -f, --fetch [host]: connect to the network by passing through the known host, if none fetch ")
  print("  -h, --help: show this help")
end

if #args ~= 1 then
  help()
  error()
end

if args[1] == "-i" or args[1] == "--init" then
  local blockchain = blockchain.Init()
  defineDirectory()
  local file = fs.open(dir .. "/blockchain.dat", "w")
  file.write(textUtils.serialize(blockchain))
  file.close()
  return
end

if args[1] == "-r" or args[1] == "--run" then
  defineDirectory()

  local bc = networking.broadcastGetBlockchainRequest()
  if bc ~= nil then
    blockchain.setBlockchain(bc)
  end

  -- Will exit if an error occurs in either mine or network listen
  -- or if "Q" is pressed 
  parallel.WaitForAny(networking.listen, mining.mine, wait_for_q)

  return
end

if args[1] == "-h" or args[1] == "--help" then
  help()
  return
end
