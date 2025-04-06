local Utils = {}

function Utils.vec3ToTable(vec)
  return {x = vec.x, y = vec.y, z = vec.z}
end

function Utils.tableToVec3(tab)
  return vector3(tab.x, tab.y, tab.z)
end

function Utils.isNullOrEmpty(str)
  return str == nil or str == ''
end

function Utils.parseCSV(str)
  local result = {}
  for match in string.gmatch(str, "[^,]+") do
      table.insert(result, match:gsub("^%s*(.-)%s*$", "%1"))
  end
  return result
end

function Utils.deepCopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
      copy = {}
      for orig_key, orig_value in next, orig, nil do
          copy[Utils.deepCopy(orig_key)] = Utils.deepCopy(orig_value)
      end
      setmetatable(copy, Utils.deepCopy(getmetatable(orig)))
  else
      copy = orig
  end
  return copy
end

function Utils.debug(message, ...)
  if not Config.Debug then return end
  
  local args = {...}
  local prefix = "^3[DEBUG]^7 "
  
  if #args > 0 then
    message = string.format(message, table.unpack(args))
  end
  
  print(prefix .. message)
end

return Utils

