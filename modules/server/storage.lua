local Storage = {}
local Utils = require 'modules/shared/utils'

function Storage.saveStashes(stashes)
  local stashesJson = json.encode(stashes)
  
  if Config.Debug then
    print("^3[DEBUG]^7 Saving " .. #stashes .. " stashes to KVP storage")
  end
  
  SetResourceKvp('aura-stashes:stashes', stashesJson)
end

function Storage.loadStashes()
  local stashesJson = GetResourceKvpString('aura-stashes:stashes')
  
  if not stashesJson then
      if Config.Debug then
        print("^3[DEBUG]^7 No stashes found in KVP storage")
      end
      return {}
  end
  
  local stashes = json.decode(stashesJson)
  
  if Config.Debug then
    print("^3[DEBUG]^7 Loaded " .. #stashes .. " stashes from KVP storage")
  end
  
  for _, stash in ipairs(stashes) do
      if stash.coords and type(stash.coords) == 'table' then
          stash.coords = vector3(stash.coords.x, stash.coords.y, stash.coords.z)
      end
      
      if not stash.zone then
          stash.zone = {
              width = Config.Target.width,
              length = Config.Target.length,
              height = Config.Target.height,
              rotation = 0
          }
      end
  end
  
  return stashes
end

function Storage.addStash(stash)
  local stashes = Storage.loadStashes()
  
  local stashToSave = Utils.deepCopy(stash)
  
  if Config.Debug then
    print("^3[DEBUG]^7 Adding stash to storage: " .. stashToSave.id)
  end
  
  if stashToSave.coords then
      stashToSave.coords = Utils.vec3ToTable(stashToSave.coords)
  end
  
  if not stashToSave.zone then
      stashToSave.zone = {
          width = Config.Target.width,
          length = Config.Target.length,
          height = Config.Target.height,
          rotation = 0
      }
  end
  
  table.insert(stashes, stashToSave)
  
  Storage.saveStashes(stashes)
end

return Storage

