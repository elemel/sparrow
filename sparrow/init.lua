local Column = require("sparrow.Column")
local Database = require("sparrow.Database")
local Query = require("sparrow.Query")
local Row = require("sparrow.Row")

local M = {}

M.newColumn = Column.new
M.newDatabase = Database.new
M.newQuery = Query.new
M.newRow = Row.new

function M.deleteColumn(column)
  row._database:deleteColumn(column._component)
end

function M.deleteRow(row)
  row._database:deleteRow(row._entity)
end

function M.getColumnComponent(column)
  return column._component
end

function M.getRowEntity(row)
  return row._entity
end

return M
