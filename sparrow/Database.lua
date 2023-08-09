local Class = require("sparrow.Class")
local Column = require("sparrow.Column")
local ffi = require("ffi")

local max = assert(math.max)

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

function M:containsColumn(component)
  return self._columns[component] ~= nil
end

function M:createColumn(component, valueType)
  return Column.new(self, component, valueType)
end

function M:getColumn(component)
  return self._columns[component]
end

function M:getValueType(component)
  local column = self._columns[component]

  if not column then
    error("No such column: " .. component)
  end

  return column:getValueType()
end

function M:dropColumn(component)
  local column = self._columns[component]

  if not column then
    error("No such column: " .. component)
  end

  column:drop()
end

function M:containsRow(entity)
  return self._archetypes[entity] ~= nil
end

function M:insertRow(cells, entity)
  if not entity then
    entity = self._maxEntity + 1
  end

  if self._archetypes[entity] then
    error("Duplicate row: " .. entity)
  end

  self._maxEntity = max(entity, self._maxEntity)

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
    error("No such row: " .. entity)
  end

  result = result or {}

  for component in pairs(archetype) do
    local column = self._columns[component]
    result[component] = column:getCell(entity)
  end

  return result
end

function M:getNextEntity(entity)
  local result = next(self._archetypes, entity)
  return result
end

function M:getArchetype(entity, result)
  local archetype = self._archetypes[entity]

  if not archetype then
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
    error("No such row: " .. entity)
  end

  for component in pairs(archetype) do
    local column = self._columns[component]
    column:setCell(entity, nil)
  end

  self._archetypes[entity] = nil
  self._rowCount = self._rowCount - 1
end

function M:containsCell(entity, component)
  local column = self._columns[component]

  if not column then
    error("No such column: " .. component)
  end

  return column:containsCell(entity)
end

function M:getCell(entity, component)
  local column = self._columns[component]

  if not column then
    error("No such column: " .. component)
  end

  return column:getCell(entity)
end

function M:setCell(entity, component, value)
  local column = self._columns[component]

  if not column then
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
