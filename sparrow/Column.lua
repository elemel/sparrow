local M = {}

function M.new(engine, component)
  if engine._columns[component] then
    error("Duplicate column: " .. component)
  end

  local column = {}

  column._engine = assert(engine)
  column._component = assert(component)

  column._indices = {}
  column._entities = {}
  column._values = {}
  column._size = 0

  engine._columns[component] = column
  return setmetatable(column, M)
end

function M.__index(column, entity)
  local index = column._indices[entity]
  return index and column._values[index]
end

function M.__newindex(column, entity, value)
  local index = column._indices[entity]

  if index then
    if value ~= nil then
      column._values[index] = value
    else
      print("Removing row " .. entity .. " from column " .. column._component)

      column._size = column._size - 1
      local lastEntity = column._entities[column._size]

      column._indices[lastEntity] = index
      column._entities[index] = lastEntity
      column._values[index] = column._values[column._size]

      column._indices[entity] = nil
      column._entities[column._size] = nil
      column._values[column._size] = nil
    end
  else
    if value ~= nil then
      print("Adding row " .. entity .. " to column " .. column._component)

      column._indices[entity] = column._size
      column._entities[column._size] = entity
      column._values[column._size] = value
      column._size = column._size + 1
    end
  end
end

return M
