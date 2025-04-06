local ESX = nil
if GetResourceState('es_extended') == 'started' then
    ESX = exports['es_extended']:getSharedObject()
end

local framework = require 'bridge/server/framework'
local inventory = require 'bridge/server/inventory'
local Storage = require 'modules/server/storage'
local Utils = require 'modules/shared/utils'

local stashes = {}

local playerDebounce = {}

inventory.setStashes(stashes)

CreateThread(function()
stashes = Storage.loadStashes()

Utils.debug("Loaded %s stashes from storage", #stashes)

if inventory.getType() == 'ox' then
    for _, stash in ipairs(stashes) do
        exports.ox_inventory:RegisterStash(
            stash.id,
            stash.label,
            stash.slots,
            stash.maxWeight,
            stash.owner,
            stash.groups,
            stash.coords
        )
        
        Utils.debug("Registered stash with ox_inventory: %s", stash.id)
    end
elseif inventory.getType() == 'qb' then
    Utils.debug("QBCore stashes will be registered when opened")
end

print(('[aura-stashes] Loaded %s stashes'):format(#stashes))

local frameworkName = framework.getName()

if frameworkName == 'qb' then
  local QBCore = exports['qb-core']:GetCoreObject()
  
  QBCore.Commands.Add(Config.Command, 'Create a custom stash', {}, Config.AdminOnly, function(source)
      TriggerClientEvent('aura-stashes:openCreator', source)
  end, 'admin')
  
  QBCore.Commands.Add('checkstashperm', 'Check stash permissions', {}, false, function(source)
      local hasAdmin = QBCore.Functions.HasPermission(source, 'admin')
      
      TriggerClientEvent('QBCore:Notify', source, 'Admin Permission: ' .. (hasAdmin and 'Yes' or 'No'), 
          hasAdmin and 'success' or 'error')
      
      Utils.debug("Player %s has admin permission: %s", source, hasAdmin and "YES" or "NO")
  end)

  QBCore.Commands.Add('activestashes', 'List all active stashes', {}, Config.AdminOnly, function(source)
      TriggerClientEvent('aura-stashes:showStashList', source)
  end, 'admin')
  
elseif frameworkName == 'esx' then
  ESX.RegisterCommand(Config.Command, 'admin', function(xPlayer, args, showError)
      xPlayer.triggerEvent('aura-stashes:openCreator')
  end, false, {help = 'Create a custom stash'})
  
  ESX.RegisterCommand('checkstashperm', 'user', function(xPlayer, args, showError)
      local isAdmin = xPlayer.getGroup() == 'admin' or xPlayer.getGroup() == 'superadmin'
      xPlayer.showNotification('Admin Permission: ' .. (isAdmin and 'Yes' or 'No'))
      Utils.debug("Player %s has admin permission: %s", xPlayer.source, isAdmin and "YES" or "NO")
  end, false, {help = 'Check stash permissions'})

  ESX.RegisterCommand('activestashes', 'admin', function(xPlayer, args, showError)
      xPlayer.triggerEvent('aura-stashes:showStashList')
  end, false, {help = 'List all active stashes'})
  
  RegisterNetEvent('esx:playerLoaded', function(playerId, xPlayer, isNew)
      Utils.debug("ESX player loaded: %s", playerId)
  end)
  
  RegisterNetEvent('esx:playerDropped', function(playerId, reason)
      Utils.debug("ESX player dropped: %s, reason: %s", playerId, reason)
  end)
else
  lib.addCommand(Config.Command, {
      help = 'Create a stash',
      restricted = Config.AdminOnly and 'group.admin',
      params = {
          {
              name = 'id',
              type = 'string',
              help = 'Stash ID (optional)',
              optional = true
          }
      }
  }, function(source, args, raw)
      Utils.debug("Player %s triggered createstash command", source)
      
      if args.id then
          TriggerClientEvent('aura-stashes:openCreator', source, args.id)
      else
          TriggerClientEvent('aura-stashes:openCreator', source)
      end
  end)
  
  lib.addCommand('checkstashperm', {
      help = 'Check stash permissions',
      restricted = false
  }, function(source, args, raw)
      local hasAdmin = IsPlayerAceAllowed(source, 'command.createstash')
      
      lib.notify(source, {
          title = 'Permission Check',
          description = 'Command Permission: ' .. (hasAdmin and 'Allowed' or 'Denied'),
          type = hasAdmin and 'success' or 'error',
          duration = 5000
      })
      
      Utils.debug("Player %s has command.createstash permission: %s", source, hasAdmin and "YES" or "NO")
  end)

  lib.addCommand('activestashes', {
    help = 'List all active stashes',
    restricted = Config.AdminOnly and 'group.admin'
  }, function(source, args, raw)
    TriggerClientEvent('aura-stashes:showStashList', source)
  end)
end
end)

lib.callback.register('aura-stashes:getInventoryType', function(source)
return inventory.getType()
end)

lib.callback.register('aura-stashes:checkPermission', function(source)
local hasPermission, reason, groups = framework.hasPermission(source, Config.Debug)
return hasPermission
end)

lib.callback.register('aura-stashes:getIdentifier', function(source)
return framework.getIdentifier(source)
end)

lib.callback.register('aura-stashes:getJob', function(source)
return framework.getJob(source)
end)

RegisterNetEvent('aura-stashes:createStash', function(stashData)
  local source = source
  if playerDebounce[source] then return end
  playerDebounce[source] = true
  
  Utils.debug("Player %s is creating a stash: %s", source, stashData.id)
  
  if not stashData.coords then
      framework.showNotification(source, 'Missing coordinates. Please set the zone first.', 'error')
      Utils.debug("Missing coordinates from player %s", source)
      playerDebounce[source] = nil
      return
  end
  
  if not stashData.coords.x or not stashData.coords.y or not stashData.coords.z then
      framework.showNotification(source, 'Invalid coordinates. Please set the zone again.', 'error')
      Utils.debug("Invalid coordinates from player %s: %s", source, json.encode(stashData.coords))
      playerDebounce[source] = nil
      return
  end
  
  if Config.AdminOnly then
    local hasPermission, reason, groups = framework.hasPermission(source, Config.Debug)
    if not hasPermission then
      framework.showNotification(source, 'You do not have admin permission to create stashes', 'error')
      
      Utils.debug("Permission denied for player %s", source)
      playerDebounce[source] = nil
      return
    end
  end
  
  if not stashData.id or not stashData.label then
    framework.showNotification(source, 'Please fill in all required fields', 'error')
    
    Utils.debug("Invalid stash data from player %s", source)
    playerDebounce[source] = nil
    return
  end
  
  if not stashData.slots or not stashData.maxWeight then
    framework.showNotification(source, 'Please fill in slots and weight fields', 'error')
    
    Utils.debug("Invalid stash data from player %s", source)
    playerDebounce[source] = nil
    return
  end
  
  if not stashData.coords then
    framework.showNotification(source, 'Missing coordinates. Please set the zone first.', 'error')
    
    Utils.debug("Missing coordinates from player %s", source)
    playerDebounce[source] = nil
    return
  end
  
  if stashData.owner then
    if stashData.allowOthers then
      stashData.owner = true
      Utils.debug("Creating shared personal stash")
    else
      stashData.owner = framework.getIdentifier(source)
      Utils.debug("Creating private personal stash for %s", stashData.owner)
    end
  end
  
  if not stashData.zone then
    stashData.zone = {
      width = Config.Target.width,
      length = Config.Target.length,
      height = Config.Target.height,
      rotation = 0
    }
  end
  
  local success = inventory.createStash(source, stashData)
  
  table.insert(stashes, stashData)
  Storage.addStash(stashData)
  TriggerClientEvent('aura-stashes:createStashTarget', -1, stashData)
  
  if success then
    framework.showNotification(source, 'Successfully created stash: ' .. stashData.label, 'success')
    
    Utils.debug("Stash created successfully: %s", stashData.id)
  else
    framework.showNotification(source, 'Stash created but no compatible inventory system was detected', 'info')
    
    Utils.debug("Stash created but no inventory system: %s", stashData.id)
  end
  
  SetTimeout(1000, function()
    playerDebounce[source] = nil
  end)
end)

RegisterNetEvent('aura-stashes:openStash', function(stashId)
local source = source

Utils.debug("Player %s is trying to open stash: %s", source, stashId)

local stash = nil
for _, s in ipairs(stashes) do
  if s.id == stashId then
      stash = s
      break
  end
end

if not stash then
  framework.showNotification(source, 'The stash you are trying to open does not exist', 'error')
  
  Utils.debug("Stash not found: %s", stashId)
  return
end

local canAccess = true

if stash.owner and type(stash.owner) == 'string' then
  local playerId = framework.getIdentifier(source)
  if playerId ~= stash.owner then
      canAccess = false
      Utils.debug("Player %s (%s) does not own stash: %s (owner: %s)", source, playerId, stashId, stash.owner)
  end
end

if canAccess then
  inventory.openStash(source, stash)
  Utils.debug("Stash opened for player %s: %s", source, stashId)
else
  framework.showNotification(source, 'You do not have permission to access this stash', 'error')
  
  Utils.debug("Access denied for player %s to stash: %s", source, stashId)
end
end)

RegisterNetEvent('aura-stashes:requestStashes', function()
local source = source
Utils.debug("Player %s requested stashes list", source)
TriggerClientEvent('aura-stashes:createStashTargets', source, stashes)
end)

lib.callback.register('aura-stashes:getAllStashes', function(source)
  local hasPermission = framework.hasPermission(source)
  if not hasPermission and Config.AdminOnly then
    return false
  end
  
  return stashes
end)

RegisterNetEvent('aura-stashes:deleteStash', function(stashId)
  local source = source
  
  if playerDebounce[source] then return end
  playerDebounce[source] = true
  
  local hasPermission = framework.hasPermission(source)
  
  if not hasPermission and Config.AdminOnly then
    framework.showNotification(source, 'You do not have permission to delete stashes', 'error')
    playerDebounce[source] = nil
    return
  end
  
  for i, stash in ipairs(stashes) do
    if stash.id == stashId then
      table.remove(stashes, i)
      Storage.saveStashes(stashes)
      TriggerClientEvent('aura-stashes:removeStashTarget', -1, stashId)
      framework.showNotification(source, 'Stash deleted: ' .. stash.label, 'success')
      Utils.debug("Stash deleted: %s", stashId)
      
      SetTimeout(1000, function()
        playerDebounce[source] = nil
      end)
      return
    end
  end
  
  framework.showNotification(source, 'Stash not found', 'error')
  playerDebounce[source] = nil
end)

RegisterNetEvent('aura-stashes:updateStash', function(updatedStash)
  local source = source
  
  if playerDebounce[source] then return end
  playerDebounce[source] = true
  
  local hasPermission = framework.hasPermission(source)
  
  if not hasPermission and Config.AdminOnly then
    framework.showNotification(source, 'You do not have permission to update stashes', 'error')
    playerDebounce[source] = nil
    return
  end
  
  for i, stash in ipairs(stashes) do
    if stash.id == updatedStash.id then
      stashes[i] = updatedStash
      Storage.saveStashes(stashes)
      
      if inventory.getType() == 'ox' then
        exports.ox_inventory:RegisterStash(
          updatedStash.id,
          updatedStash.label,
          updatedStash.slots,
          updatedStash.maxWeight,
          updatedStash.owner,
          updatedStash.groups,
          updatedStash.coords
        )
        Utils.debug("Re-registered updated stash with ox_inventory: %s", updatedStash.id)
      end
      
      TriggerClientEvent('aura-stashes:removeStashTarget', -1, stash.id)
      TriggerClientEvent('aura-stashes:createStashTarget', -1, updatedStash)
      
      framework.showNotification(source, 'Stash updated: ' .. updatedStash.label, 'success')
      Utils.debug("Stash updated: %s", updatedStash.id)
      
      SetTimeout(1000, function()
        playerDebounce[source] = nil
      end)
      return
    end
  end
  
  framework.showNotification(source, 'Stash not found', 'error')
  playerDebounce[source] = nil
end)

AddEventHandler('playerDropped', function()
  local source = source
  playerDebounce[source] = nil
end)

lib.addCommand('activestashes', {
  help = 'List all active stashes',
  restricted = Config.AdminOnly and 'group.admin'
}, function(source, args, raw)
  TriggerClientEvent('aura-stashes:showStashList', source)
end)

