local Class = require("sparrow.Class")
local ffi = require("ffi")

local M = Class.new()

function M:init(database, component, valueType)
  self._database = assert(database)
  self._component = assert(component)
  self._valueType = valueType

  assert(type(component) == "string", "Invalid component type")
  assert(valueType == nil or type(valueType) == "string", "Invalid value type")
  assert(not database._columns[component])

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
  database._columnCount = database._columnCount + 1
end

function M:drop()
  assert(self._database, "Already dropped")

  for i = self._size - 1, 0, -1 do
    local entity = self._entities[i]

    local archetype = self._database._archetypes[entity]
    assert(archetype[self._component])
    archetype[self._component] = nil
  end

  self._database._columns[self._component] = nil
  self._database._version = self._database._version + 1
  self._database._columnCount = self._database._columnCount - 1
  self._database._cellCount = self._database._cellCount - self._size
  self._database = nil
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

function M:getValueSize()
  return self._valueSize
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

  if index then
    return self._values[index]
  else
    if not self._database._archetypes[entity] then
      assert(type(entity) == "number", "Invalid entity type")
      error("No such row: " .. entity)
    end

    return nil
  end
end

function M:setCell(entity, value)
  local index = self._indices[entity]

  if index then
    if value ~= nil then
      self._values[index] = value
    else
      local archetype = assert(self._database._archetypes[entity])
      assert(archetype[self._component])

      self._size = self._size - 1
      local lastEntity = self._entities[self._size]

      self._indices[lastEntity] = index
      self._entities[index] = lastEntity
      self._values[index] = self._values[self._size]

      self._indices[entity] = nil
      self._entities[self._size] = 0
      self._values[self._size] = self._defaultValue

      archetype[self._component] = nil
      self._database._cellCount = self._database._cellCount - 1
    end
  else
    local archetype = self._database._archetypes[entity]

    if not archetype then
      assert(type(entity) == "number", "Invalid entity type")
      error("No such row: " .. entity)
    end

    assert(not archetype[self._component])

    if value ~= nil then
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

      archetype[self._component] = true
      self._database._cellCount = self._database._cellCount + 1
    end
  end
end

return M
