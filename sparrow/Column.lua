local Class = require("sparrow.Class")
local ffi = require("ffi")

local M = Class.new()

function M:init(database, component, valueType)
  self._database = assert(database)
  self._component = assert(component)

  if self._database._columns[self._component] then
    error("Duplicate column: " .. self._component)
  end

  self._valueType = valueType
  self._valueSize = valueType and ffi.sizeof(valueType)
  self._valueArrayType = valueType and valueType .. "[?]"
  self._defaultValue = valueType and ffi.new(valueType)

  self._size = 0
  self._capacity = 2

  self._indices = {}
  self._entities = ffi.new(database._entityArrayType, self._capacity)
  self._values = self._valueArrayType
      and ffi.new(self._valueArrayType, self._capacity)
    or {}

  database._columns[component] = self
  database._version = database._version + 1
end

function M:drop()
  assert(self._database._columns[self._component] == self, "Already dropped")

  for i = self._size - 1, 0, -1 do
    local entity = self._entities[i]

    local rowArchetype = self._database._rowArchetypes[entity]
    assert(rowArchetype[self._component])
    rowArchetype[self._component] = nil
  end

  self._database._columns[self._component] = nil
  self._database._version = self._database._version + 1
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
      local rowArchetype = assert(self._database._rowArchetypes[entity])
      assert(rowArchetype[self._component])

      self._size = self._size - 1
      local lastEntity = self._entities[self._size]

      self._indices[lastEntity] = index
      self._entities[index] = lastEntity
      self._values[index] = self._values[self._size]

      self._indices[entity] = nil
      self._entities[self._size] = 0
      self._values[self._size] = self._defaultValue

      rowArchetype[self._component] = nil
    end
  else
    if value ~= nil then
      local rowArchetype = self._database._rowArchetypes[entity]
      assert(not rowArchetype[self._component])

      if rowArchetype == nil then
        assert(type(entity) == "number", "Invalid entity type")
        error("No such row: " .. entity)
      end

      if self._size == self._capacity then
        local newCapacity = self._capacity * 2

        local newEntities =
          ffi.new(self._database._entityArrayType, newCapacity)

        ffi.copy(
          newEntities,
          self._entities,
          self._database._entitySize * self._size
        )

        if self._valueArrayType then
          local newValues = ffi.new(self._valueArrayType, newCapacity)
          ffi.copy(newValues, self._values, self._valueSize * self._size)

          self._values = newValues
        end

        self._entities = newEntities
        self._capacity = newCapacity
      end

      self._indices[entity] = self._size
      self._entities[self._size] = entity
      self._values[self._size] = value
      self._size = self._size + 1

      rowArchetype[self._component] = true
    end
  end
end

return M
