local framework = {}
local frameworkName = nil

local function detectFramework()
  if GetResourceState('es_extended') == 'started' then
      frameworkName = 'esx'
      return exports['es_extended']:getSharedObject()
  elseif GetResourceState('qbx-core') == 'started' then
      frameworkName = 'qbx'
      return {}
  elseif GetResourceState('qb-core') == 'started' then
      frameworkName = 'qb'
      return exports['qb-core']:GetCoreObject()
  end
  frameworkName = 'none'
  return nil
end

local Core = detectFramework()

function framework.hasPermission()
  if not Config.AdminOnly then return true end
  
  if frameworkName == 'esx' then
      local playerData = Core.GetPlayerData()
      return playerData.group == 'admin' or playerData.group == 'superadmin'
  elseif frameworkName == 'qbx' then
      return lib.callback.await('aura-stashes:checkPermission', false)
  elseif frameworkName == 'qb' then
      local Player = Core.Functions.GetPlayerData()
      if Player.admin then return true end
  else
      return lib.callback.await('aura-stashes:checkPermission', false)
  end
  
  return false
end

function framework.getIdentifier()
  if frameworkName == 'esx' then
      local playerData = Core.GetPlayerData()
      return playerData.identifier
  elseif frameworkName == 'qbx' or frameworkName == 'none' then
      return lib.callback.await('aura-stashes:getIdentifier', false)
  else
      local Player = Core.Functions.GetPlayerData()
      return Player.citizenid
  end
end

function framework.getJob()
  if frameworkName == 'esx' then
      local playerData = Core.GetPlayerData()
      return {
          name = playerData.job.name,
          label = playerData.job.label,
          grade = {
              level = playerData.job.grade,
              name = playerData.job.grade_name,
              label = playerData.job.grade_label,
              salary = playerData.job.grade_salary
          }
      }
  elseif frameworkName == 'qbx' or frameworkName == 'none' then
      return lib.callback.await('aura-stashes:getJob', false)
  else
      local Player = Core.Functions.GetPlayerData()
      return Player.job
  end
end

function framework.showNotification(message, type)
  if frameworkName == 'esx' then
      TriggerEvent('esx:showNotification', message)
  elseif frameworkName == 'qb' then
      TriggerEvent('QBCore:Notify', message, type or 'primary')
  else
      lib.notify({
          title = 'Notification',
          description = message,
          type = type or 'info'
      })
  end
end

function framework.getName()
  return frameworkName
end

return framework

