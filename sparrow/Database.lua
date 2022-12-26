local Class = require("sparrow.Class")
local DataType = require("sparrow.DataType")

local M = Class.new()

function M:init()
  self._columns = {}
  self._version = 1

  self._rows = {}
  self._rowCount = 0

  self._entityType = DataType.new("double")
  self._nextEntity = 1
end

function M:generateEntity()
  self._nextEntity = self._nextEntity + 1
  return self._nextEntity - 1
end

function M:getColumn(component)
  return self._columns[component]
end

function M:getRow(entity)
  return self._rows[entity]
end

function M:getRowCount()
  return self._rowCount
end

function M:getCell(entity, component)
  if not self._rows[entity] then
    assert(type(entity) == "number", "Invalid entity type")
    error("No such row: " .. entity)
  end

  local column = self._columns[component]

  if not column then
    assert(type(component) == "string", "Invalid component type")
    error("No such column: " .. component)
  end

  return column:getCell(entity)
end

function M:setCell(entity, component, value)
  if not self._rows[entity] then
    assert(type(entity) == "number", "Invalid entity type")
    error("No such row: " .. entity)
  end

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

function M:deleteRow(entity)
  if not self._rows[entity] then
    error("No such row: " .. entity)
  end

  for _, column in pairs(self._columns) do
    column:setCell(entity, nil)
  end

  self._rows[entity] = nil
  self._rowCount = self._rowCount - 1
end

function M:deleteColumn(component)
  if not self._columns[component] then
    error("No such column: " .. component)
  end

  self._columns[component] = nil
  self._version = self._version + 1
end

return M
