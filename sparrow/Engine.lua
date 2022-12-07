local Class = require("sparrow.Class")
local ffi = require("ffi")

local M = Class.new()

function M:init()
  self._columns = {}
  self._rows = {}

  self._entitySize = ffi.sizeof("double")
  self._entityAllocator = ffi.typeof("double[?]")

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
