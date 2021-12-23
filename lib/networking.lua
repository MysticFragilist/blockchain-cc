local networking = {
  _VERSION     = "network-node.lua 0.0.1",
  _DESCRIPTION = "A network node client for accessing blockchain made in Lua (5.1-3, LuaJIT)",
  _URL         = "https://github.com/MysticFragilist/blockchain-cc",
  _LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2021 Samuel Montambault Software

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

-- We will use rednet API to send messages to the network
-- Let's assume rednet modem will be placed on top of the computer
local protocolName = "minecoin-1.0.0"
local modemSide = "top"

-- Possible "action":
-- REQ: This call is a request, it should be answered by the peer with a RES
-- RES: This call is a response, if it was meant for this peer, answer it
-- Possible "command":
-- get-blockchain: This command is used to request the blockchain as a table

local getBlockchainRequest = { action = "REQ", command = "get-blockchain" }


local function open()
  if not rednet.isOpen(modemSide) then
    rednet.open(modemSide)
  end
end

local function close()
  if rednet.isOpen(modemSide) then
    rednet.close(modemSide)
  end
end

function networking.listen()
  open()
  while true do
    local senderID, message = rednet.receive(protocolName, 2)
    local messageAsObj = textUtils.unserialize(message)
    if messageAsObj.action == "REQ" then
      if messageAsObj.command == "get-blockchain" then
        local response = { action = "RES", command = "get-blockchain", data = textUtils.serialize(blockchain.getBlockchain()) }
        rednet.send(senderID, textUtils.serialize(response), protocolName)
      end
    end
    local _, key = os.pullEvent("key")
  end
  close()
end

function networking.fetchBlockchain()
  open()

  rednet.broadcast(textUtils.serialize(getBlockchainRequest), protocolName)
  local senderID, message = rednet.receive(protocolName)
  local messageAsObj = textUtils.unserialize(message)
  if messageAsObj.action == "RES" and messageAsObj.command == "get-blockchain" then
    return textUtils.unserialize(messageAsObj.data)
  end
  return nil
end

function networking.broadcastLatest()
  open()
  local res = { action = "RES", command = "get-blockchain", data = textUtils.serialize(blockchain.getBlockchain()) }
  rednet.broadcast(textUtils.serialize(res), protocolName)
  local senderID, message = rednet.receive(protocolName)
  local messageAsObj = textUtils.unserialize(message)
  if messageAsObj.action == "RES" and messageAsObj.command == "get-blockchain" then
    return textUtils.unserialize(messageAsObj.data)
  end
  return nil
end


return networking
