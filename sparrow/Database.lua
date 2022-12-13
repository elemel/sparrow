local Class = require("sparrow.Class")
local DataType = require("sparrow.DataType")

local M = Class.new()

function M:init()
  self._columns = {}
  self._rows = {}

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

return M
