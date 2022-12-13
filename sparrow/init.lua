local Column = require("sparrow.Column")
local Database = require("sparrow.Database")
local Query = require("sparrow.Query")
local Row = require("sparrow.Row")

local M = {}

M.newColumn = Column.new
M.newDatabase = Database.new
M.newQuery = Query.new
M.newRow = Row.new

return M
