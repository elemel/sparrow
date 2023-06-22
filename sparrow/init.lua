local Database = require("sparrow.Database")
local Query = require("sparrow.Query")

local M = {}

M.newDatabase = Database.new
M.newQuery = Query.new

return M
