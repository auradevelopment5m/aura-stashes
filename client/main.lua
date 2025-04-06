local framework = require 'bridge/client/framework'
local UI = require 'modules/client/ui'
local Targets = require 'modules/client/targets'

local isUIActive = false

RegisterCommand(Config.Command, function()
  if Config.AdminOnly then
      local hasPermission = lib.callback.await('aura-stashes:checkPermission', false)
      if not hasPermission then
          framework.showNotification('You do not have admin permission to create stashes', 'error')
          return
      end
  end
  
  local inventoryType = lib.callback.await('aura-stashes:getInventoryType', false)
  UI.showStashCreator(nil, inventoryType)
  isUIActive = true
end, false)

RegisterKeyMapping(Config.Command, 'Create a stash', 'keyboard', '')

RegisterNetEvent('aura-stashes:openCreator', function(prefilledData)
  local inventoryType = lib.callback.await('aura-stashes:getInventoryType', false)
  UI.showStashCreator(prefilledData, inventoryType)
  isUIActive = true
end)

RegisterNetEvent('aura-stashes:createStashTargets', function(stashes)
  Targets.removeAllTargets()
  
  for _, stash in ipairs(stashes) do
      Targets.createStashTarget(stash)
  end
  
  print('[aura-stashes] Created ' .. #stashes .. ' stash targets')
end)

RegisterNetEvent('aura-stashes:createStashTarget', function(stash)
  if not stash then
    print('[aura-stashes] Error: Received nil stash in createStashTarget')
    return
  end
  
  if not stash.coords then
    print('[aura-stashes] Error: Stash is missing coordinates: ' .. stash.id)
    return
  end
  
  Targets.createStashTarget(stash)
  print('[aura-stashes] Created stash target: ' .. stash.id)
end)

RegisterNetEvent('aura-stashes:removeStashTarget', function(stashId)
  Targets.removeStashTarget(stashId)
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
  TriggerServerEvent('aura-stashes:requestStashes')
end)

RegisterNetEvent('esx:playerLoaded', function()
  TriggerServerEvent('aura-stashes:requestStashes')
end)

AddEventHandler('onResourceStop', function(resourceName)
  if resourceName == GetCurrentResourceName() then
      Targets.removeAllTargets()
      
      SetNuiFocus(false, false)
      isUIActive = false
  end
end)

AddEventHandler('onClientResourceStart', function(resourceName)
  if resourceName == GetCurrentResourceName() then
      Wait(1000)
      TriggerServerEvent('aura-stashes:requestStashes')
  end
end)

RegisterNetEvent('aura-stashes:showStashList', function()
  local allStashes = lib.callback.await('aura-stashes:getAllStashes', false)
  
  if not allStashes then
    lib.notify({
      title = 'Error',
      description = 'You do not have permission to view stashes',
      type = 'error'
    })
    return
  end
  
  if #allStashes == 0 then
    lib.notify({
      title = 'No Stashes',
      description = 'There are no stashes available',
      type = 'info'
    })
    return
  end
  
  SendNUIMessage({
    type = 'showStashList',
    stashes = allStashes
  })
  SetNuiFocus(true, true)
  isUIActive = true
end)

RegisterNetEvent('aura-stashes:hideUI', function()
  UI.hideStashCreator()
  UI.hideStashList()
  
  SetNuiFocus(false, false)
  TriggerScreenblurFadeOut(0)
  
  SetTimeout(500, function()
    SetNuiFocus(false, false)
  end)
  
  isUIActive = false
end)

local escapeHandled = false
RegisterCommand('forceCloseStashUI', function()
  if isUIActive and not escapeHandled then
    escapeHandled = true
    
    SendNUIMessage({
      type = 'hideUI',
      forceHide = true
    })
    
    TriggerEvent('aura-stashes:hideUI')
    
    SetNuiFocus(false, false)
    
    SetTimeout(100, function()
      SetNuiFocus(false, false)
    end)
    
    SetTimeout(1000, function()
      escapeHandled = false
    end)
    
    isUIActive = false
  end
end, false)

CreateThread(function()
  while true do
    Wait(1000)
    
    if not isUIActive then
      SetNuiFocus(false, false)
    end
  end
end)

