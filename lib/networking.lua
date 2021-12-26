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
networking = {}
blockchain = blockchain or require 'lib/blockchain'

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

local getLatestBlockRequest = { action = "REQ", command = "get-latest-block" }

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

local function handleGetBlockChainResponse(messageAsObj)
  local blockchainReceived = textUtils.unserialize(messageAsObj.data)
  if #blockchainReceived > 0 then
    local latestBlockReceived = blockchainReceived[#blockchainReceived]
    local latestBlockHeld = blockchain.getLatestBlock()
    if latestBlockReceived.index > latestBlockHeld.index then
      print("blockchain possibly behind. We got: " .. latestBlockHeld.index .. " peer has: " .. latestBlockReceived.index)
      if latestBlockHeld.hash == latestBlockReceived.previousHash then
        if blockchain.addBlockToChain(latestBlockReceived) then
          networking.broadcastMessage(getLatestBlockRequest)
        end
      elseif #blockchainReceived == 1 then
        print("We have to query the chain from our peer");
        networking.broadcastGetBlockchainRequest()
      else
        print("Received blockchain is longer than current blockchain");
        blockchain.replaceChain(blockchainReceived)
      end
    else
      print("received blockchain is not longer than received blockchain. Do nothing");
    end
  else
    print("No blockchain received")
  end
end

-- MAIN LISTEN FUNCTION
function networking.listen()
  open()
  while true do
    local senderID, message = rednet.receive(protocolName, 2)
    local messageAsObj = textUtils.unserialize(message)
    if messageAsObj.action == "REQ" then
      if messageAsObj.command == "get-blockchain" then
        local response = { action = "RES", command = "get-blockchain", data = textUtils.serialize(blockchain.getBlockchain()) }
        rednet.send(senderID, textUtils.serialize(response), protocolName)
      elseif messageAsObj.command == "get-latest-block" then
        local response = { action = "RES", command = "get-latest-block", data = textUtils.serialize(blockchain.getLatestBlock()) }
        rednet.send(senderID, textUtils.serialize(response), protocolName)
      end
    elseif messageAsObj.action == "RES" then
      handleGetBlockChainResponse(messageAsObj)
    end
  end
  close()
end


-- Broadcast a request to get the blockchain or the lastest block
function networking.broadcastMessage(msgToBroadcastAsObj)
  open()

  rednet.broadcast(textUtils.serialize(msgToBroadcastAsObj), protocolName)
  local senderID, message = rednet.receive(protocolName)
  local messageAsObj = textUtils.unserialize(message)
  if messageAsObj.action == "RES" and messageAsObj.command == "get-blockchain" then
    return textUtils.unserialize(messageAsObj.data)
  end
  return nil
end

function networking.broadcastGetBlockchainRequest()
  return networking.broadcastMessage(getBlockchainRequest)
end

-- Broadcast a response to all the peer after an update (making sure everyone is up to date)
function networking.broadcastBlockchain()
  open()
  local res = { action = "RES", command = "get-blockchain", data = textUtils.serialize(blockchain.getBlockchain()) }
  rednet.broadcast(textUtils.serialize(res), protocolName)
end


return networking
