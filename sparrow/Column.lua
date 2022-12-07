local ffi = require("ffi")

local M = {}

function M.new(engine, component, typeName)
  if engine._columns[component] then
    error("Duplicate column: " .. component)
  end

  local column = {}

  column._engine = assert(engine)
  column._component = assert(component)

  column._typeName = typeName
  column._valueSize = typeName and ffi.sizeof(typeName)
  column._defaultValue = typeName and ffi.typeof(typeName)()
  column._valueAllocator = typeName and ffi.typeof(typeName .. "[?]")

  column._size = 0
  column._capacity = 2

  column._indices = {}
  column._entities = engine._entityAllocator(column._capacity)
  column._values = column._valueAllocator and column._valueAllocator(column._capacity) or {}

  engine._columns[component] = column
  return setmetatable(column, M)
end

function M.__index(column, entity)
  local index = column._indices[entity]
  return index and column._values[index]
end

function M.__newindex(column, entity, value)
  local index = column._indices[entity]

  if index then
    if value ~= nil then
      column._values[index] = value
    else
      -- print("Removing row " .. entity .. " from column " .. column._component)

      column._size = column._size - 1
      local lastEntity = column._entities[column._size]

      column._indices[lastEntity] = index
      column._entities[index] = lastEntity
      column._values[index] = column._values[column._size]

      column._indices[entity] = nil
      column._entities[column._size] = 0
      column._values[column._size] = column._defaultValue
    end
  else
    if value ~= nil then
      if column._size == column._capacity then
        local newCapacity = column._capacity * 2
        print("Reallocating column " .. column._component .. " to capacity " .. newCapacity)

        local newEntities = column._engine._entityAllocator(newCapacity)
        ffi.copy(newEntities, column._entities, column._engine._entitySize * column._size)

        if column._typeName then
          local newValues = column._valueAllocator(newCapacity)
          ffi.copy(newValues, column._values, column._valueSize * column._size)

          column._values = newValues
        end

        column._entities = newEntities
        column._capacity = newCapacity
      end

      -- print("Adding row " .. entity .. " to column " .. column._component)
      column._indices[entity] = column._size
      column._entities[column._size] = entity
      column._values[column._size] = value
      column._size = column._size + 1
    end
  end
end

return M
