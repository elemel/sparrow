local Class = require("sparrow.Class")
local tableMod = require("sparrow.table")

local concat = assert(table.concat)
local copy = assert(tableMod.copy)
local insert = assert(table.insert)
local sort = assert(table.sort)
local values = assert(tableMod.values)

local M = Class.new()

local function getColumns(engine, components)
  local columns = {}

  for i, component in ipairs(components) do
    local column = engine._columns[component]

    if not column then
      error("No such column: " .. component)
    end

    columns[i] = column
  end

  return columns
end

local function generateEachRowFunction(inputArity, unputArity, outputArity)
  assert(inputArity >= 1, "Not implemented")

  buffer = {}
  insert(
    buffer,
    [[return function(query, system)
  query:sortColumns()

  for i = query._sortedInputColumns[1]._size - 1, 0, -1 do
    local entity = query._sortedInputColumns[1]._entities[i]

    if ]]
  )

  if inputArity == 1 and unputArity == 0 then
    insert(buffer, "true")
  else
    for i = 2, inputArity do
      if i >= 3 then
        insert(buffer, " and\n        ")
      end

      insert(buffer, "query._sortedInputColumns[")
      insert(buffer, i)
      insert(buffer, "]._indices[entity]")
    end

    for i = 1, unputArity do
      if inputArity >= 2 or i >= 2 then
        insert(buffer, " and\n        ")
      end

      insert(buffer, "not query._sortedUnputColumns[")
      insert(buffer, i)
      insert(buffer, "]._indices[entity]")
    end
  end

  insert(buffer, " then\n")
  insert(buffer, "      ")

  if outputArity >= 1 then
    for i = 1, outputArity do
      if i >= 2 then
        insert(buffer, ",\n        ")
      end

      insert(buffer, "query._outputColumns[")
      insert(buffer, i)
      insert(buffer, "][entity]")
    end

    insert(buffer, " = ")
  end

  insert(buffer, "system(")

  for i = 1, inputArity do
    if i >= 2 then
      insert(buffer, ",")
    end

    insert(buffer, "\n          query._inputColumns[")
    insert(buffer, i)
    insert(buffer, "][entity]")
  end

  insert(
    buffer,
    [[)
    end
  end
end
]]
  )

  local code = concat(buffer)
  local f, message = load(code)

  if message then
    print()
    print(code)
    error(message)
  else
    print(
      "Arities: " .. inputArity .. ", " .. outputArity .. ", " .. unputArity
    )
    print()
    print(code)
  end

  return f()
end

function M:init(engine, inputs, unputs, outputs)
  self._engine = assert(engine)

  self._inputColumns = getColumns(engine, inputs or {})
  self._unputColumns = getColumns(engine, unputs or {})
  self._outputColumns = getColumns(engine, outputs or {})

  self._sortedInputColumns = values(self._inputColumns)
  self._sortedUnputColumns = values(self._unputColumns)

  self.forEach = generateEachRowFunction(
    #self._inputColumns,
    #self._unputColumns,
    #self._outputColumns
  )
end

function M:sortColumns()
  sort(self._sortedInputColumns, function(a, b)
    return a._size < b._size
  end)

  sort(self._sortedUnputColumns, function(a, b)
    return a._size > b._size
  end)
end

return M
