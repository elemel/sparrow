local DataType = require("sparrow.DataType")
local ffi = require("ffi")

local M = {}

function M.new(database, component, valueType)
  if database._columns[component] then
    error("Duplicate column: " .. component)
  end

  local column = {}

  column._database = assert(database)
  column._component = assert(component)

  column._valueType = valueType and DataType.new(valueType)
  column._defaultValue = column._valueType and column._valueType.type()

  column._size = 0
  column._capacity = 2

  column._indices = {}
  column._entities = database._entityType.arrayType(column._capacity)
  column._values = column._valueType
      and column._valueType.arrayType(column._capacity)
    or {}

  database._columns[component] = column
  database._version = database._version + 1

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
        print(
          "Reallocating column "
            .. column._component
            .. " to capacity "
            .. newCapacity
        )

        local newEntities = column._database._entityType.arrayType(newCapacity)
        ffi.copy(
          newEntities,
          column._entities,
          column._database._entityType.size * column._size
        )

        if column._valueType then
          local newValues = column._valueType.arrayType(newCapacity)
          ffi.copy(
            newValues,
            column._values,
            column._valueType.size * column._size
          )

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
