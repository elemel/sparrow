local Class = require("sparrow.Class")
local DataType = require("sparrow.DataType")
local ffi = require("ffi")

local M = Class.new()

function M:init(database, component, valueType)
  self._database = assert(database)
  self._component = assert(component)

  if self._database._columns[self._component] then
    error("Duplicate column: " .. self._component)
  end

  self._valueType = valueType
  self._dataType = self._valueType and DataType.new(self._valueType)
  self._defaultValue = self._dataType and self._dataType.type()

  self._size = 0
  self._capacity = 2

  self._indices = {}
  self._entities = database._entityType.arrayType(self._capacity)
  self._values = self._dataType and self._dataType.arrayType(self._capacity)
    or {}

  database._columns[component] = self
  database._version = database._version + 1
end

function M:delete()
  self._database:deleteColumn(self._component)
end

function M:getDatabase()
  return self._database
end

function M:getComponent()
  return self._component
end

function M:getValueType()
  return self._valueType
end

function M:getSize()
  return self._size
end

function M:getCapacity()
  return self._capacity
end

function M:getIndex(entity)
  return self._indices[entity]
end

function M:getEntity(index)
  return self._entities[index]
end

function M:getCell(entity)
  local index = self._indices[entity]
  return index and self._values[index]
end

function M:setCell(entity, value)
  local index = self._indices[entity]

  if index then
    if value ~= nil then
      self._values[index] = value
    else
      self._size = self._size - 1
      local lastEntity = self._entities[self._size]

      self._indices[lastEntity] = index
      self._entities[index] = lastEntity
      self._values[index] = self._values[self._size]

      self._indices[entity] = nil
      self._entities[self._size] = 0
      self._values[self._size] = self._defaultValue
    end
  else
    if value ~= nil then
      if self._size == self._capacity then
        local newCapacity = self._capacity * 2

        local newEntities = self._database._entityType.arrayType(newCapacity)
        ffi.copy(
          newEntities,
          self._entities,
          self._database._entityType.size * self._size
        )

        if self._dataType then
          local newValues = self._dataType.arrayType(newCapacity)
          ffi.copy(newValues, self._values, self._dataType.size * self._size)

          self._values = newValues
        end

        self._entities = newEntities
        self._capacity = newCapacity
      end

      self._indices[entity] = self._size
      self._entities[self._size] = entity
      self._values[self._size] = value
      self._size = self._size + 1
    end
  end
end

return M
