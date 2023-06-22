local Column = require("sparrow.Column")
local Database = require("sparrow.Database")
local Query = require("sparrow.Query")

local M = {}

M.newColumn = Column.new
M.newDatabase = Database.new
M.newQuery = Query.new

return M
