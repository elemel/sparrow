local Class = require("sparrow.Class")

local M = Class.new()

function M:init(database, cells)
  self._database = assert(database)
  self._entity = database:generateEntity()

  database._rows[self._entity] = self
  database._rowCount = self._database._rowCount + 1

  if cells then
    for component, value in pairs(cells) do
      self:setCell(component, value)
    end
  end
end

function M:delete()
  self._database:deleteRow(self._entity)
end

function M:getDatabase()
  return self._database
end

function M:getEntity()
  return self._entity
end

function M:getCell(component)
  local column = self._database._columns[component]
  return column and column:getCell(self._entity)
end

function M:setCell(component, value)
  local column = self._database._columns[component]

  if not column then
    error("No such column: " .. component)
  end

  column:setCell(self._entity, value)
end

return M
