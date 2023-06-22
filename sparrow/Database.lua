local Class = require("sparrow.Class")
local ffi = require("ffi")

local M = Class.new()

function M:init()
  self._columns = {}
  self._version = 1

  self._archetypes = {}
  self._rowCount = 0

  self._entityType = "double"
  self._entitySize = ffi.sizeof(self._entityType)
  self._entityArrayType = self._entityType .. "[?]"
  self._maxEntity = 0
end

function M:getColumn(component)
  return self._columns[component]
end

function M:getArchetype(entity, archetype)
  local entityArchetype = self._archetypes[entity]

  if entityArchetype == nil then
    assert(type(entity) == "number", "Invalid entity type")
    error("No such row: " .. entity)
  end

  archetype = archetype or {}

  for component in pairs(entityArchetype) do
    archetype[component] = true
  end

  return archetype
end

function M:getRowCount()
  return self._rowCount
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

return M
