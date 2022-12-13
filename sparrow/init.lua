local Column = require("sparrow.Column")
local Engine = require("sparrow.Engine")
local Query = require("sparrow.Query")
local Row = require("sparrow.Row")

local M = {}

M.newColumn = Column.new
M.newEngine = Engine.new
M.newQuery = Query.new
M.newRow = Row.new

return M
