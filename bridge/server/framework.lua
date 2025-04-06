local framework = {}
local frameworkName = nil
local Utils = require 'modules/shared/utils'

local function detectFramework()
  if GetResourceState('es_extended') == 'started' then
      frameworkName = 'esx'
      return exports['es_extended']:getSharedObject()
  elseif GetResourceState('qbx-core') == 'started' then
      frameworkName = 'qbx'
      return exports.qbx_core:GetCoreObject()
  elseif GetResourceState('qb-core') == 'started' then
      frameworkName = 'qb'
      return exports['qb-core']:GetCoreObject()
  end
  frameworkName = 'none'
  return nil
end

local Core = detectFramework()

function framework.hasPermission(source, debug)
  if not Config.AdminOnly then 
      if debug then
          Utils.debug("Player %s is allowed because Config.AdminOnly is false", source)
      end
      return true, "Config.AdminOnly is false", nil
  end
  
  if frameworkName == 'esx' then
      local xPlayer = Core.GetPlayerFromId(source)
      if not xPlayer then return false, "Player not found", {} end
      
      local isAdmin = xPlayer.getGroup() == 'admin' or xPlayer.getGroup() == 'superadmin'
      
      if debug then
          Utils.debug("Framework: ESX")
          Utils.debug("Is admin: %s", isAdmin and "Yes" or "No")
      end
      
      if isAdmin then
          return true, "Has admin ESX permission", {"admin"}
      end
  elseif frameworkName == 'qbx' then
      local hasAdmin = IsPlayerAceAllowed(source, 'command.createstash')
      
      if debug then
          Utils.debug("Framework: QBX")
          Utils.debug("Has 'command.createstash' permission: %s", hasAdmin and "Yes" or "No")
      end
      
      if hasAdmin then
          return true, "Has 'command.createstash' ACE permission", {"admin"}
      end
  elseif frameworkName == 'qb' then
      local hasAdmin = QBCore.Functions.HasPermission(source, 'admin')
      
      if debug then
          Utils.debug("Framework: QBCore")
          Utils.debug("Has 'admin' permission: %s", hasAdmin and "Yes" or "No")
      end
      
      if hasAdmin then
          return true, "Has 'admin' QBCore permission", {"admin"}
      end
  else
      local hasAdmin = IsPlayerAceAllowed(source, 'command.createstash')
      
      if debug then
          Utils.debug("Framework: None (Using native ACE)")
          Utils.debug("Has 'command.createstash' permission: %s", hasAdmin and "Yes" or "No")
      end
      
      if hasAdmin then
          return true, "Has 'command.createstash' ACE permission", {"admin"}
      end
  end
  
  if debug then
      Utils.debug("Player %s does not have permission", source)
  end
  
  return false, "No matching permission found", {}
end

function framework.getIdentifier(source)
  if frameworkName == 'esx' then
      local xPlayer = Core.GetPlayerFromId(source)
      if not xPlayer then return nil end
      return xPlayer.identifier
  elseif frameworkName == 'qbx' then
      local Player = exports.qbx_core:GetPlayer(source)
      if not Player then return nil end
      return Player.citizenid
  elseif frameworkName == 'qb' then
      local Player = Core.Functions.GetPlayer(source)
      if not Player then return nil end
      return Player.PlayerData.citizenid
  else
      local identifiers = GetPlayerIdentifiers(source)
      for _, id in ipairs(identifiers) do
          if string.find(id, 'license:') then
              return string.sub(id, 9)
          end
      end
  end
  
  return nil
end

function framework.getJob(source)
  if frameworkName == 'esx' then
      local xPlayer = Core.GetPlayerFromId(source)
      if not xPlayer then return nil end
      local job = xPlayer.getJob()
      return {
          name = job.name,
          label = job.label,
          grade = {
              level = job.grade,
              name = job.grade_name,
              label = job.grade_label,
              salary = job.grade_salary
          }
      }
  elseif frameworkName == 'qbx' then
      local Player = exports.qbx_core:GetPlayer(source)
      if not Player then return nil end
      return Player.job
  elseif frameworkName == 'qb' then
      local Player = Core.Functions.GetPlayer(source)
      if not Player then return nil end
      return Player.PlayerData.job
  else
      return { name = 'unemployed', grade = { level = 0 } }
  end
end

function framework.showNotification(source, message, type)
  if frameworkName == 'esx' then
      local xPlayer = Core.GetPlayerFromId(source)
      if xPlayer then
          xPlayer.showNotification(message)
      else
          TriggerClientEvent('esx:showNotification', source, message)
      end
  elseif frameworkName == 'qb' then
      TriggerClientEvent('QBCore:Notify', source, message, type or 'primary')
  else
      lib.notify(source, {
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

