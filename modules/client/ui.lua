local UI = {}
local isUIOpen = false
local Utils = require 'modules/shared/utils'
local zoneState = {
  active = false,
  width = 1.0,
  length = 1.0,
  height = 1.0,
  coords = nil,
  rotation = 0,
  frozen = false
}

function UI.showStashCreator(prefilledData, inventoryType)
  if isUIOpen then return end

  Utils.debug("Opening stash creator UI")

  TriggerScreenblurFadeIn(400)

  SetNuiFocus(true, true)

  SendNUIMessage({
    type = 'showUI',
    stashData = prefilledData,
    inventoryType = inventoryType
  })

  isUIOpen = true
end

function UI.hideStashCreator()
  if not isUIOpen then return end

  Utils.debug("Closing stash creator UI")

  TriggerScreenblurFadeOut(0)

  SetNuiFocus(false, false)

  SendNUIMessage({
    type = 'hideUI',
    showControls = false,
    showDimensions = false,
    forceHide = true
  })

  Wait(100)

  TriggerScreenblurFadeOut(0)
  SetNuiFocus(false, false)

  isUIOpen = false

  zoneState = {
    active = false,
    width = 1.0,
    length = 1.0,
    height = 1.0,
    coords = nil,
    rotation = 0,
    frozen = false
  }

  SetTimeout(500, function()
    SetNuiFocus(false, false)
  end)
end

function UI.hideStashList()
  Utils.debug("Closing stash list UI")

  SetNuiFocus(false, false)

  SendNUIMessage({
    type = 'hideUI',
    showControls = false,
    showDimensions = false,
    forceHide = true
  })

  Wait(100)
  
  SetNuiFocus(false, false)

  isUIOpen = false
  
  SetTimeout(500, function()
    SetNuiFocus(false, false)
  end)
end

function UI.startZoneCreation()
  SetNuiFocus(false, false)
  
  TriggerScreenblurFadeOut(0)
  
  Utils.debug("Starting zone creation")
  
  SendNUIMessage({
    type = 'hideUI',
    showControls = true,
    showDimensions = true
  })
  
  zoneState.active = true
  zoneState.coords = GetEntityCoords(PlayerPedId())
  zoneState.frozen = false
  
  local positionThread = nil
  positionThread = CreateThread(function()
    while zoneState.active do
      if not zoneState.frozen then
          local hit, _, coords, normal, _ = lib.raycast.fromCamera(511, 4, 10.0)
          if hit then
              zoneState.coords = vector3(
                  coords.x,
                  coords.y,
                  coords.z + (zoneState.height / 2)
              )
              
              SendNUIMessage({
                  type = 'updateDimensions',
                  zoneData = {
                      width = zoneState.width,
                      length = zoneState.length,
                      height = zoneState.height,
                      coords = zoneState.coords,
                      rotation = zoneState.rotation,
                      frozen = zoneState.frozen
                  }
              })
          end
      end
      Wait(50)
    end
    
    if positionThread then
      positionThread = nil
    end
  end)

  CreateThread(function()
    while zoneState.active do
        Wait(0)
        
        DisableControlAction(0, 24, true)
        DisableControlAction(0, 25, true)
        DisableControlAction(0, 140, true)
        DisableControlAction(0, 141, true)
        DisableControlAction(0, 142, true)
        DisableControlAction(0, 257, true)
        DisableControlAction(0, 263, true)
        DisableControlAction(0, 264, true)
        
        EnableControlAction(0, 1, true)
        EnableControlAction(0, 2, true)
        EnableControlAction(0, 237, true)
        
        DrawZone()
        
        if IsControlJustPressed(0, 189) then
            zoneState.width = math.max(0.5, zoneState.width - 0.1)
            Utils.debug("Width decreased: %s", zoneState.width)
            SendNUIMessage({
                type = 'updateDimensions',
                zoneData = {
                    width = zoneState.width,
                    length = zoneState.length,
                    height = zoneState.height,
                    coords = zoneState.coords,
                    rotation = zoneState.rotation,
                    frozen = zoneState.frozen
                }
            })
        elseif IsControlJustPressed(0, 190) then
            zoneState.width = math.min(10.0, zoneState.width + 0.1)
            Utils.debug("Width increased: %s", zoneState.width)
            SendNUIMessage({
                type = 'updateDimensions',
                zoneData = {
                    width = zoneState.width,
                    length = zoneState.length,
                    height = zoneState.height,
                    coords = zoneState.coords,
                    rotation = zoneState.rotation,
                    frozen = zoneState.frozen
                }
            })
        elseif IsControlJustPressed(0, 188) then
            zoneState.height = math.min(10.0, zoneState.height + 0.1)
            Utils.debug("Height increased: %s", zoneState.height)
            SendNUIMessage({
                type = 'updateDimensions',
                zoneData = {
                    width = zoneState.width,
                    length = zoneState.length,
                    height = zoneState.height,
                    coords = zoneState.coords,
                    rotation = zoneState.rotation,
                    frozen = zoneState.frozen
                }
            })
        elseif IsControlJustPressed(0, 187) then
            zoneState.height = math.max(0.5, zoneState.height - 0.1)
            Utils.debug("Height decreased: %s", zoneState.height)
            SendNUIMessage({
                type = 'updateDimensions',
                zoneData = {
                    width = zoneState.width,
                    length = zoneState.length,
                    height = zoneState.height,
                    coords = zoneState.coords,
                    rotation = zoneState.rotation,
                    frozen = zoneState.frozen
                }
            })
        elseif IsControlJustPressed(0, 20) then
            zoneState.length = math.min(10.0, zoneState.length + 0.1)
            Utils.debug("Length increased: %s", zoneState.length)
            SendNUIMessage({
                type = 'updateDimensions',
                zoneData = {
                    width = zoneState.width,
                    length = zoneState.length,
                    height = zoneState.height,
                    coords = zoneState.coords,
                    rotation = zoneState.rotation,
                    frozen = zoneState.frozen
                }
            })
        elseif IsControlJustPressed(0, 73) then
            zoneState.length = math.max(0.5, zoneState.length - 0.1)
            Utils.debug("Length decreased: %s", zoneState.length)
            SendNUIMessage({
                type = 'updateDimensions',
                zoneData = {
                    width = zoneState.width,
                    length = zoneState.length,
                    height = zoneState.height,
                    coords = zoneState.coords,
                    rotation = zoneState.rotation,
                    frozen = zoneState.frozen
                }
            })
        elseif IsControlJustPressed(0, 201) then
            zoneState.active = false
            Utils.debug("Zone confirmed")
            
            SendNUIMessage({
                type = 'updateZone',
                zoneData = {
                    width = zoneState.width,
                    length = zoneState.length,
                    height = zoneState.height,
                    coords = zoneState.coords,
                    rotation = zoneState.rotation,
                    frozen = zoneState.frozen
                },
                showControls = false,
                showDimensions = false
            })
            
            TriggerScreenblurFadeIn(400)
            
            SendNUIMessage({
                type = 'showUI'
            })
            SetNuiFocus(true, true)
        elseif IsControlJustPressed(0, 202) then
            zoneState.active = false
            Utils.debug("Zone creation cancelled")
            
            TriggerScreenblurFadeIn(400)
            
            SendNUIMessage({
                type = 'showUI',
                showControls = false,
                showDimensions = false
            })
            SetNuiFocus(true, true)
        elseif IsDisabledControlJustPressed(0, 24) then
            zoneState.frozen = not zoneState.frozen
            Utils.debug("Zone frozen: %s", tostring(zoneState.frozen))
            SendNUIMessage({
                type = 'updateDimensions',
                zoneData = {
                    width = zoneState.width,
                    length = zoneState.length,
                    height = zoneState.height,
                    coords = zoneState.coords,
                    rotation = zoneState.rotation,
                    frozen = zoneState.frozen
                }
            })
        end
        
        if IsControlJustPressed(0, 14) then
            zoneState.rotation = (zoneState.rotation + 5) % 360
            Utils.debug("Rotation increased: %s", zoneState.rotation)
            SendNUIMessage({
                type = 'updateDimensions',
                zoneData = {
                    width = zoneState.width,
                    length = zoneState.length,
                    height = zoneState.height,
                    coords = zoneState.coords,
                    rotation = zoneState.rotation,
                    frozen = zoneState.frozen
                }
            })
        elseif IsControlJustPressed(0, 15) then
            zoneState.rotation = (zoneState.rotation - 5) % 360
            Utils.debug("Rotation decreased: %s", zoneState.rotation)
            SendNUIMessage({
                type = 'updateDimensions',
                zoneData = {
                    width = zoneState.width,
                    length = zoneState.length,
                    height = zoneState.height,
                    coords = zoneState.coords,
                    rotation = zoneState.rotation,
                    frozen = zoneState.frozen
                }
            })
        end
    end
  end)
end

function DrawZone()
  if not zoneState.coords then return end

  local coords = zoneState.coords
  local width = zoneState.width
  local length = zoneState.length
  local height = zoneState.height
  local rotation = zoneState.rotation

  local rad = math.rad(rotation)
  local cos_r = math.cos(rad)
  local sin_r = math.sin(rad)

  local bl = vector3(
    coords.x + ((-width/2) * cos_r - (-length/2) * sin_r),
    coords.y + ((-width/2) * sin_r + (-length/2) * cos_r),
    coords.z - height/2
  )

  local br = vector3(
    coords.x + ((width/2) * cos_r - (-length/2) * sin_r),
    coords.y + ((width/2) * sin_r + (-length/2) * cos_r),
    coords.z - height/2
  )

  local fl = vector3(
    coords.x + ((-width/2) * cos_r - (length/2) * sin_r),
    coords.y + ((-width/2) * sin_r + (length/2) * cos_r),
    coords.z - height/2
  )

  local fr = vector3(
    coords.x + ((width/2) * cos_r - (length/2) * sin_r),
    coords.y + ((width/2) * sin_r + (length/2) * cos_r),
    coords.z - height/2
  )

  local tbl = vector3(bl.x, bl.y, coords.z + height/2)
  local tbr = vector3(br.x, br.y, coords.z + height/2)
  local tfl = vector3(fl.x, fl.y, coords.z + height/2)
  local tfr = vector3(fr.x, fr.y, coords.z + height/2)

  DrawLine(bl.x, bl.y, bl.z, br.x, br.y, br.z, 0, 122, 255, 255)
  DrawLine(br.x, br.y, br.z, fr.x, fr.y, fr.z, 0, 122, 255, 255)
  DrawLine(fr.x, fr.y, fr.z, fl.x, fl.y, fl.z, 0, 122, 255, 255)
  DrawLine(fl.x, fl.y, fl.z, bl.x, bl.y, bl.z, 0, 122, 255, 255)

  DrawLine(tbl.x, tbl.y, tbl.z, tbr.x, tbr.y, tbr.z, 0, 122, 255, 255)
  DrawLine(tbr.x, tbr.y, tbr.z, tfr.x, tfr.y, tfr.z, 0, 122, 255, 255)
  DrawLine(tfr.x, tfr.y, tfr.z, tfl.x, tfl.y, tfl.z, 0, 122, 255, 255)
  DrawLine(tfl.x, tfl.y, tfl.z, tbl.x, tbl.y, tbl.z, 0, 122, 255, 255)

  DrawLine(bl.x, bl.y, bl.z, tbl.x, tbl.y, tbl.z, 0, 122, 255, 255)
  DrawLine(br.x, br.y, br.z, tbr.x, tbr.y, tbr.z, 0, 122, 255, 255)
  DrawLine(fr.x, fr.y, fr.z, tfr.x, tfr.y, tfr.z, 0, 122, 255, 255)
  DrawLine(fl.x, fl.y, fl.z, tfl.x, tfl.y, tfl.z, 0, 122, 255, 255)

  DrawPoly(tbl.x, tbl.y, tbl.z, tbr.x, tbr.y, tbr.z, bl.x, bl.y, bl.z, 0, 122, 255, 50)
  DrawPoly(tbr.x, tbr.y, tbr.z, br.x, br.y, br.z, bl.x, bl.y, bl.z, 0, 122, 255, 50)

  DrawPoly(tbr.x, tbr.y, tbr.z, tfr.x, tfr.y, tfr.z, br.x, br.y, br.z, 0, 122, 255, 50)
  DrawPoly(tfr.x, tfr.y, tfr.z, fr.x, fr.y, fr.z, br.x, br.y, br.z, 0, 122, 255, 50)

  DrawPoly(tfr.x, tfr.y, tfr.z, tfl.x, tfl.y, tfl.z, fr.x, fr.y, fr.z, 0, 122, 255, 50)
  DrawPoly(tfl.x, tfl.y, tfl.z, fl.x, fl.y, fl.z, fr.x, fr.y, fr.z, 0, 122, 255, 50)

  DrawPoly(tfl.x, tfl.y, tfl.z, tbl.x, tbl.y, tbl.z, fl.x, fl.y, fl.z, 0, 122, 255, 50)
  DrawPoly(tbl.x, tbl.y, tbl.z, bl.x, bl.y, bl.z, fl.x, fl.y, fl.z, 0, 122, 255, 50)

  local color = zoneState.frozen and {r = 0, g = 255, b = 0, a = 100} or {r = 0, g = 122, b = 255, a = 100}

  DrawMarker(
    1,
    coords.x, coords.y, coords.z,
    0.0, 0.0, 0.0,
    0.0, 0.0, 0.0,
    0.1, 0.1, 0.1,
    color.r, color.g, color.b, color.a,
    false,
    false,
    2,
    false,
    nil,
    nil,
    false
  )

  Utils.debug("Box dimensions: W:%s L:%s H:%s", width, length, height)
  Utils.debug("Box position: X:%s Y:%s Z:%s", coords.x, coords.y, coords.z)
end

RegisterNUICallback('closeUI', function(data, cb)
  UI.hideStashCreator()
  
  SetNuiFocus(false, false)
  
  SetTimeout(500, function()
    SetNuiFocus(false, false)
  end)
  
  cb({})
end)

RegisterNUICallback('setZone', function(data, cb)
  UI.startZoneCreation()
  cb({})
end)

local actionDebounce = false

RegisterNUICallback('createStash', function(data, cb)
  if actionDebounce then 
    cb({})
    return 
  end
  
  actionDebounce = true
  
  UI.hideStashCreator()

  if not zoneState.coords then
    lib.notify({
      title = 'Error',
      description = 'You need to set the zone first',
      type = 'error'
    })
    
    actionDebounce = false
    cb({})
    return
  end

  data.zone = {
    width = zoneState.width,
    length = zoneState.length,
    height = zoneState.height,
    rotation = zoneState.rotation
  }
  
  if not data.coords and zoneState.coords then
      data.coords = zoneState.coords
  end

  Utils.debug("Creating stash with data:")
  Utils.debug("ID: %s", data.id)
  Utils.debug("Label: %s", data.label)
  Utils.debug("Dimensions: W:%s L:%s H:%s R:%s", data.zone.width, data.zone.length, data.zone.height, data.zone.rotation)
  if data.coords then
      Utils.debug("Coords: X:%s Y:%s Z:%s", data.coords.x, data.coords.y, data.coords.z)
  else
      Utils.debug("WARNING: No coordinates available for this stash!")
  end

  TriggerServerEvent('aura-stashes:createStash', data)

  SetNuiFocus(false, false)
  
  SetTimeout(1000, function()
    actionDebounce = false
  end)
  
  cb({})
end)

RegisterNUICallback('closeStashList', function(data, cb)
  UI.hideStashList()
  
  SetNuiFocus(false, false)
  
  cb({})
end)

RegisterNUICallback('teleportToStash', function(data, cb)
  if actionDebounce then 
    cb({})
    return 
  end
  
  actionDebounce = true
  
  if data.coords then
    SetEntityCoords(PlayerPedId(), data.coords.x, data.coords.y, data.coords.z)
    lib.notify({
      title = 'Teleported',
      description = 'You have been teleported to the stash location',
      type = 'success'
    })
  else
    lib.notify({
      title = 'Error',
      description = 'No coordinates available for this stash',
      type = 'error'
    })
  end

  UI.hideStashList()
  
  SetNuiFocus(false, false)
  
  SetTimeout(1000, function()
    actionDebounce = false
  end)
  
  cb({})
end)

RegisterNUICallback('deleteStash', function(data, cb)
  if actionDebounce then 
    cb({})
    return 
  end
  
  actionDebounce = true
  
  TriggerServerEvent('aura-stashes:deleteStash', data.id)
  UI.hideStashList()
  
  SetNuiFocus(false, false)
  
  SetTimeout(1000, function()
    actionDebounce = false
  end)
  
  cb({})
end)

RegisterNUICallback('updateStash', function(data, cb)
  if actionDebounce then 
    cb({})
    return 
  end
  
  actionDebounce = true
  
  SendNUIMessage({
    type = 'hideUI',
    forceHide = true
  })
  
  SetNuiFocus(false, false)
  
  TriggerScreenblurFadeOut(0)
  
  TriggerServerEvent('aura-stashes:updateStash', data)
  
  UI.hideStashCreator()
  
  SetTimeout(100, function()
    SetNuiFocus(false, false)
    
    SetTimeout(500, function()
      actionDebounce = false
    end)
  end)
  
  cb({})
end)

return UI

