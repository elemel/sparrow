local tableMod = require("sparrow.table")

local copy = assert(tableMod.copy)

local M = {}

function M.new(engine, cells)
  local row = {}

  row._engine = assert(engine)
  local entity = engine:generateEntity()
  row._entity = entity

  setmetatable(row, M)
  engine._rows[entity] = row

  if cells then
    for component, value in pairs(cells) do
      row[component] = value
    end
  end

  return row
end

function M.__index(row, component)
  local column = row._engine._columns[component]
  return column and column[row._entity]
end

function M.__newindex(row, component, value)
  local column = row._engine._columns[component]

  if not column then
    error("No such column: " .. component)
    return
  end

  column[row._entity] = value
end

return M
