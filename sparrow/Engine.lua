local Class = require("sparrow.Class")

local M = Class.new()

function M:init()
  self._nextEntity = 1
  self._rows = {}
  self._columns = {}
end

function M:generateEntity()
  self._nextEntity = self._nextEntity + 1
  return self._nextEntity - 1
end

return M
