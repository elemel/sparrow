local Class = require("sparrow.Class")
local DataType = require("sparrow.DataType")
local ffi = require("ffi")
local logMod = require("sparrow.log")

local isLogged = assert(logMod.isLogged)
local log = assert(logMod.log)

local M = Class.new()

function M:init(database, component, valueType)
  self._database = assert(database)
  self._component = assert(component)

  if self._database._columns[self._component] then
    error("Duplicate column: " .. self._component)
  end

  self._valueType = valueType and DataType.new(valueType)
  self._defaultValue = self._valueType and self._valueType.type()

  self._size = 0
  self._capacity = 2

  self._indices = {}
  self._entities = database._entityType.arrayType(self._capacity)
  self._values = self._valueType
      and self._valueType.arrayType(self._capacity)
    or {}

  database._columns[component] = self
  database._version = database._version + 1
end

function M:getValue(entity)
  local index = self._indices[entity]
  return index and self._values[index]
end

function M:setValue(entity, value)
  local index = self._indices[entity]

  if index then
    if value ~= nil then
      self._values[index] = value
    else
      if isLogged("debug") then
        log(
          "debug",
          "Removing row " .. entity .. " from column " .. self._component
        )
      end

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

        log(
          "info",
          "Reallocating "
            .. self._component
            .. " column to capacity "
            .. newCapacity
        )

        local newEntities = self._database._entityType.arrayType(newCapacity)
        ffi.copy(
          newEntities,
          self._entities,
          self._database._entityType.size * self._size
        )

        if self._valueType then
          local newValues = self._valueType.arrayType(newCapacity)
          ffi.copy(
            newValues,
            self._values,
            self._valueType.size * self._size
          )

          self._values = newValues
        end

        self._entities = newEntities
        self._capacity = newCapacity
      end

      if isLogged("debug") then
        log(
          "debug",
          "Adding row " .. entity .. " to " .. self._component .. " column"
        )
      end

      self._indices[entity] = self._size
      self._entities[self._size] = entity
      self._values[self._size] = value
      self._size = self._size + 1
    end
  end
end

return M
