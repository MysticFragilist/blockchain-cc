blockchain = {
  _VERSION     = "blockchain.lua 0.0.1",
  _DESCRIPTION = "Blockchain made in Lua (5.1-3, LuaJIT)",
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
local md5 = require './externals/md5'
local networking = require './networking'
local mining = require './mining'

local blockchainInstance = {}
local dir = "./data"
blockchain.Block = {index = 0, previousHash = "0", timestamp = 1640195948, data = "generic data", hash = "", difficulty = 2, nonce = 0}

function blockchain.calculateHash(block)
  return md5.sumhexa(block.index .. block.previousHash .. block.timestamp .. block.data .. block.difficulty .. block.nonce)
end

function blockchain.Block:new (o)
  o = o or { index = 0, previousHash = "0", timestamp = 1640195948, data = "my genesis block", difficulty = 2, nonce = 0 }  -- create genesis if user does not provide one
  o.hash = blockchain.calculateHash(o)

  setmetatable(o, self)
  self.__index = self
  return o
end

function blockchain.Init()
  local genesis = blockchain.Block:new()
  print("Genesis block: " .. genesis.hash)
  blockchain.setBlockchain({ genesis })
  return blockchainInstance
end

function blockchain.getBlockchain()
  return blockchainInstance
end

function blockchain.getLength()
  return table.getn(blockchainInstance)
end

function blockchain.setBlockchain(blockchain)
  blockchainInstance = blockchain
  local file = fs.open(dir .. "/blockchain.dat", "w")
  file.write(textUtils.serialize(blockchainInstance))
  file.close()
end

function blockchain.loadBlockchainFromFile(blockchain)
  blockchainInstance = blockchain
  local file = fs.open(dir .. "/blockchain.dat", "r")
  local fileToStr = file.readAll()
  file.close()
  blockchainInstance = textUtils.unserialize(fileToStr)
end

local function addBlock (previousBlock, newBlock)
  if blockchain.IsNewBlockValid(newBlock, previousBlock) then
    blockchain.push(newBlock);
  end
end

function blockchain.generateNextBlock (blockData)
  local previousBlock = blockchainInstance[blockchain.getLength()]
  local nextIndex = previousBlock.index + 1
  local nextTimestamp = os.epoch("utc") / 1000

  local difficulty = mining.getDifficulty(blockchain.getBlockchain())

  local newBlock = mining.mineBlock(nextIndex, previousBlock.hash, nextTimestamp, blockData, difficulty)
  local nextHash = blockchain.calculateHash(newBlock)
  newBlock.hash = nextHash

  addBlock(previousBlock, newBlock)
  networking.broadcastLatest()
  return newBlock;
end

local function isValidTimestamp (newBlock, previousBlock)
  return previousBlock.timestamp - 60 < newBlock.timestamp and
    newBlock.timestamp - 60 < blockchainInstance[blockchain.getLength()].timestamp
end

local function isValidBlockStructure (block)
  return type(block.index) == 'number'
    and type(block.hash) == 'string'
    and type(block.previousHash) == 'string'
    and type(block.timestamp) == 'number'
    and type(block.data) == 'string'
end

local function hashMatchesBlockContent (block)
  local blockHash = blockchain.calculateHash(block)
  return blockHash == block.hash;
end

local function hasValidHash (block)

  if not hashMatchesBlockContent(block) then
    print('invalid hash, got:' + block.hash)
    return false;
  end

  if not mining.hashMatchesDifficulty(block.hash, block.difficulty) then
    print('block difficulty not satisfied. Expected: ' + block.difficulty + 'got: ' + block.hash)
    return false;
  end
  return true;
end

function blockchain.IsNewBlockValid (newBlock, previousBlock)
  if not isValidBlockStructure(newBlock) then
    print('Invalid block structure')
    return false
  end

  if previousBlock.index + 1 ~= newBlock.index then
    print("Invalid index")
    return false
  elseif previousBlock.hash ~= newBlock.previousHash then
    print("Invalid previousHash")
    return false
  elseif not isValidTimestamp(newBlock, previousBlock) then
    print('invalid timestamp');
    return false;
  elseif not hasValidHash(newBlock) then
    return false
  end
  return true
end

local function isChainValid (blockchainToValidate)
  local function IsValidGenesis (block)
    return textUtils.serialize(block) == textUtils.serialize(blockchain.Block:new());
  end

  if not IsValidGenesis(blockchainToValidate[1]) then
    return false;
  end

  for i=2,table.getn(blockchainToValidate) do
    if not blockchain.IsNewBlockValid(blockchainToValidate[i], blockchainToValidate[i - 1]) then
      return false
    end
  end
  return true
end

function blockchain.ReplaceChain (newBlocks)
  if isChainValid(newBlocks) and newBlocks.length > blockchain.getBlockchain().length then
      print("Received blockchain is valid. Replacing current blockchain with received blockchain")
      blockchain.setBlockchain(newBlocks)
      networking.broadcastLatest()
  else
      print("Received blockchain invalid")
  end
end

return blockchain

