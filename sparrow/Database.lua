local Class = require("sparrow.Class")
local Column = require("sparrow.Column")
local ffi = require("ffi")

local M = Class.new()

function M:init(entityType)
  self._entityType = entityType or "double"
  self._entitySize = ffi.sizeof(self._entityType)
  self._entityArrayType = self._entityType .. "[?]"

  self._columns = {}
  self._version = 1

  self._maxEntity = 0
  self._archetypes = {}

  self._columnCount = 0
  self._rowCount = 0
  self._cellCount = 0
end

function M:getEntityType()
  return self._entityType
end

function M:getEntitySize()
  return self._entitySize
end

function M:createColumn(component, valueType)
  if self._columns[component] then
    error("Duplicate column: " .. component)
  end

  return Column.new(self, component, valueType)
end

function M:getColumn(component)
  return self._columns[component]
end

function M:dropColumn(component)
  local column = self._columns[component]

  if not column then
    assert(type(component) == "string", "Invalid component type")
    error("No such column: " .. component)
  end

  column:drop()
end

function M:insertRow(cells)
  local entity = self._maxEntity + 1
  self._maxEntity = entity

  self._archetypes[entity] = {}
  self._rowCount = self._rowCount + 1

  if cells then
    for component, value in pairs(cells) do
      self:setCell(entity, component, value)
    end
  end

  return entity
end

function M:getRow(entity, result)
  local archetype = self._archetypes[entity]

  if not archetype then
    assert(type(entity) == "number", "Invalid entity type")
    error("No such row: " .. entity)
  end

  result = result or {}

  for component in pairs(archetype) do
    local column = self._columns[component]
    result[component] = column:getCell(entity)
  end

  return result
end

function M:getArchetype(entity, result)
  local archetype = self._archetypes[entity]

  if not archetype then
    assert(type(entity) == "number", "Invalid entity type")
    error("No such row: " .. entity)
  end

  result = result or {}

  for component in pairs(archetype) do
    result[component] = true
  end

  return result
end

function M:deleteRow(entity)
  local archetype = self._archetypes[entity]

  if not archetype then
    assert(type(entity) == "number", "Invalid entity type")
    error("No such row: " .. entity)
  end

  for component in pairs(archetype) do
    local column = self._columns[component]
    column:setCell(entity, nil)
  end

  self._archetypes[entity] = nil
  self._rowCount = self._rowCount - 1
end

function M:getCell(entity, component)
  local column = self._columns[component]

  if not column then
    assert(type(component) == "string", "Invalid component type")
    error("No such column: " .. component)
  end

  return column:getCell(entity)
end

function M:setCell(entity, component, value)
  local column = self._columns[component]

  if not column then
    assert(type(component) == "string", "Invalid component type")
    error("No such column: " .. component)
  end

  column:setCell(entity, value)
end

function M:getVersion()
  return self._version
end

function M:getColumnCount()
  return self._columnCount
end

function M:getRowCount()
  return self._rowCount
end

function M:getCellCount()
  return self._cellCount
end

return M
