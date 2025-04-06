local Targets = {}
local activeTargets = {}
local Utils = require 'modules/shared/utils'

function Targets.createStashTarget(stash)
if not Config.Target.enabled then return end

if activeTargets[stash.id] then return end

if not stash then
    Utils.debug("Cannot create target for stash: nil stash object")
    return
end

if not stash.coords then
    Utils.debug("Cannot create target for stash: %s - missing coordinates", stash.id or "unknown")
    return
end

Utils.debug("Creating target with coords: X:%s Y:%s Z:%s", 
    stash.coords.x, stash.coords.y, stash.coords.z)

local width = stash.zone and stash.zone.width or Config.Target.width
local length = stash.zone and stash.zone.length or Config.Target.length
local height = stash.zone and stash.zone.height or Config.Target.height
local rotation = stash.zone and stash.zone.rotation or 0

Utils.debug("Creating target for stash: %s", stash.id)
Utils.debug("Dimensions: W:%s L:%s H:%s R:%s", width, length, height, rotation)
Utils.debug("Coords: X:%s Y:%s Z:%s", stash.coords.x, stash.coords.y, stash.coords.z)

local targetId

if GetResourceState('ox_target') == 'started' then
    targetId = exports.ox_target:addBoxZone({
        coords = stash.coords,
        size = vector3(width, length, height),
        rotation = rotation,
        debug = Config.Debug,
        options = {
            {
                name = 'stash_' .. stash.id,
                icon = 'fas fa-box',
                label = 'Open Storage',
                onSelect = function()
                    TriggerServerEvent('aura-stashes:openStash', stash.id)
                end,
                canInteract = function()
                    return true
                end
            }
        }
    })
elseif GetResourceState('qb-target') == 'started' then
    targetId = 'stash_' .. stash.id
    exports['qb-target']:AddBoxZone(
        targetId,
        stash.coords,
        width,
        length,
        {
            name = targetId,
            heading = rotation,
            debugPoly = Config.Debug,
            minZ = stash.coords.z - (height / 2),
            maxZ = stash.coords.z + (height / 2)
        },
        {
            options = {
                {
                    type = 'client',
                    icon = 'fas fa-box',
                    label = 'Open Storage',
                    action = function()
                        TriggerServerEvent('aura-stashes:openStash', stash.id)
                    end
                }
            },
            distance = Config.Target.distance
        }
    )
end

if targetId then
    activeTargets[stash.id] = targetId
    Utils.debug("Target created with ID: %s", tostring(targetId))
end

if Config.Target.drawSprite then
    local sprite = Config.Target.sprite
    
    CreateThread(function()
        local spriteId = AddBlipForCoord(stash.coords.x, stash.coords.y, stash.coords.z)
        SetBlipSprite(spriteId, 1) 
        SetBlipColour(spriteId, 3) 
        SetBlipScale(spriteId, 0.8)
        SetBlipAsShortRange(spriteId, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(stash.label)
        EndTextCommandSetBlipName(spriteId)
        
        activeTargets[stash.id .. '_sprite'] = spriteId
        
        Utils.debug("Sprite created for stash: %s", stash.id)
    end)
end
end

function Targets.removeStashTarget(stashId)
if not Config.Target.enabled then return end
if not activeTargets[stashId] then return end

Utils.debug("Removing target for stash: %s", stashId)

if GetResourceState('ox_target') == 'started' then
    exports.ox_target:removeZone(activeTargets[stashId])
elseif GetResourceState('qb-target') == 'started' then
    exports['qb-target']:RemoveZone(activeTargets[stashId])
end

if activeTargets[stashId .. '_sprite'] then
    RemoveBlip(activeTargets[stashId .. '_sprite'])
    activeTargets[stashId .. '_sprite'] = nil
    
    Utils.debug("Sprite removed for stash: %s", stashId)
end

activeTargets[stashId] = nil
end

function Targets.removeAllTargets()
Utils.debug("Removing all targets")

for stashId, _ in pairs(activeTargets) do
    if not string.find(stashId, '_sprite') then
        Targets.removeStashTarget(stashId)
    end
end
end

return Targets

