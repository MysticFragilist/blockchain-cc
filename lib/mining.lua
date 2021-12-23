local mining = {
  _VERSION     = "mining.lua 0.0.1",
  _DESCRIPTION = "The mining module for the blockchain in Lua (5.1-3, LuaJIT)",
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
-- in seconds
mining.BLOCK_GENERATION_INTERVAL = 10

-- in blocks
mining.DIFFICULTY_ADJUSTMENT_INTERVAL = 10

function string.fromhex(str)
  return (str:gsub('..', function (cc)
      return string.char(tonumber(cc, 16))
  end))
end

function mining.hashMatchesDifficulty (hash, difficulty)
  local hashInBinary = string.fromhex(hash)
  for i = 1, difficulty do
    if string.sub(hashInBinary, i, i) ~= "0" then
      return false
    end
  end
  return true
end


function mining.mineBlock (index, previousHash, timestamp, data, difficulty)
  local nonce = 0
  while true do
    local hash = blockchain.calculateHash({ index, previousHash, timestamp, data, difficulty, nonce })
    if mining.hashMatchesDifficulty(hash, difficulty) then
        return blockchain.Block:new{ index, hash, previousHash, timestamp, data, difficulty, nonce }
    end
    nonce = nonce + 1
  end
end

local function getAdjustedDifficulty (latestBlock, aBlockchain)
  local prevAdjustmentBlock = aBlockchain[blockchain.getLength() - mining.DIFFICULTY_ADJUSTMENT_INTERVAL]
  local timeExpected = mining.BLOCK_GENERATION_INTERVAL * mining.DIFFICULTY_ADJUSTMENT_INTERVAL
  local timeTaken = latestBlock.timestamp - prevAdjustmentBlock.timestamp
  if timeTaken < timeExpected / 2 then
    return prevAdjustmentBlock.difficulty + 1;
  elseif timeTaken > timeExpected * 2 then
    return prevAdjustmentBlock.difficulty - 1;
  else
    return prevAdjustmentBlock.difficulty;
  end
end

function mining.getDifficulty (aBlockchain)
  local latestBlock = aBlockchain[blockchain.getLength() - 1];
  if (latestBlock.index % mining.DIFFICULTY_ADJUSTMENT_INTERVAL == 0 and latestBlock.index ~= 0) then
    return getAdjustedDifficulty(latestBlock, aBlockchain);
  else
    return latestBlock.difficulty;
  end
end


return mining