local inventory = {}
local Utils = require 'modules/shared/utils'

local stashes = {}

local function detectInventory()
  if GetResourceState('ox_inventory') == 'started' then
      return 'ox'
  elseif GetResourceState('qb-inventory') == 'started' then
      return 'qb'
  end
  return nil
end

local inventoryType = detectInventory()

function inventory.createStash(source, stashData)
  if inventoryType == 'ox' then
      local exists = false
      for _, stash in ipairs(stashes) do
          if stash.id == stashData.id then
              exists = true
              break
          end
      end
      
      if not exists then
          exports.ox_inventory:RegisterStash(
              stashData.id,
              stashData.label,
              stashData.slots,
              stashData.maxWeight,
              stashData.owner,
              stashData.groups,
              stashData.coords
          )
          Utils.debug("Registered new stash with ox_inventory: %s", stashData.id)
      else
          Utils.debug("Stash already registered, skipping registration: %s", stashData.id)
      end
      
      TriggerClientEvent('ox_inventory:openInventory', source, 'stash', stashData.id)
      return true
  elseif inventoryType == 'qb' then
      local data = {
          label = stashData.label,
          slots = stashData.slots,
          maxweight = stashData.maxWeight
      }
      
      local stashId = stashData.id
      if stashData.owner and type(stashData.owner) == 'string' then
          stashId = stashData.id .. "_" .. stashData.owner
      end
      
      exports['qb-inventory']:OpenInventory(source, stashId, data)
      return true
  else
      local framework = require 'bridge/server/framework'
      framework.showNotification(source, 'Stash created: ' .. stashData.label .. ' (No inventory system detected)', 'info')
      return false
  end
end

function inventory.openStash(source, stashData)
  if inventoryType == 'ox' then
      TriggerClientEvent('ox_inventory:openInventory', source, 'stash', stashData.id)
      return true
  elseif inventoryType == 'qb' then
      local stashId = stashData.id
      if stashData.owner and type(stashData.owner) == 'string' then
          stashId = stashData.id .. "_" .. stashData.owner
      end
      
      local data = {
          label = stashData.label,
          slots = stashData.slots,
          maxweight = stashData.maxWeight
      }
      
      exports['qb-inventory']:OpenInventory(source, stashId, data)
      return true
  else
      local framework = require 'bridge/server/framework'
      framework.showNotification(source, 'Cannot open stash: No inventory system detected', 'error')
      return false
  end
end

function inventory.getType()
  return inventoryType
end

function inventory.setStashes(stashesTable)
  stashes = stashesTable
end

return inventory

