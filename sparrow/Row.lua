local tableMod = require("sparrow.table")

local copy = assert(tableMod.copy)

local M = {}

function M.new(database, cells)
  local row = {}

  row._database = assert(database)
  local entity = database:generateEntity()
  row._entity = entity

  setmetatable(row, M)
  database._rows[entity] = row

  if cells then
    for component, value in pairs(cells) do
      row[component] = value
    end
  end

  return row
end

function M.__index(row, component)
  local column = row._database._columns[component]
  return column and column[row._entity]
end

function M.__newindex(row, component, value)
  local column = row._database._columns[component]

  if not column then
    error("No such column: " .. component)
    return
  end

  column[row._entity] = value
end

return M
