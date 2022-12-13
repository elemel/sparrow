local Class = require("sparrow.Class")
local tableMod = require("sparrow.table")

local concat = assert(table.concat)
local copy = assert(tableMod.copy)
local insert = assert(table.insert)
local sort = assert(table.sort)
local values = assert(tableMod.values)

local M = Class.new()

local function getColumns(database, components)
  local columns = {}

  for i, component in ipairs(components) do
    local column = database._columns[component]

    if not column then
      error("No such column: " .. component)
    end

    columns[i] = column
  end

  return columns
end

local function generateEachRowFunction(
  inputArity,
  optionalInputArity,
  excludedInputArity,
  outputArity
)
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

  if inputArity == 1 and excludedInputArity == 0 then
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

    for i = 1, excludedInputArity do
      if inputArity >= 2 or i >= 2 then
        insert(buffer, " and\n        ")
      end

      insert(buffer, "not query._sortedExcludedInputColumns[")
      insert(buffer, i)
      insert(buffer, "]._indices[entity]")
    end
  end

  insert(buffer, " then\n      ")

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

  insert(buffer, "system(entity")

  for i = 1, inputArity do
    insert(buffer, ",\n          query._inputColumns[")
    insert(buffer, i)
    insert(buffer, "][entity]")
  end

  for i = 1, optionalInputArity do
    insert(buffer, ",\n          query._optionalInputColumns[")
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
      "Generated for-each function for arity "
        .. inputArity
        .. ", "
        .. optionalInputArity
        .. ", "
        .. excludedInputArity
        .. ", "
        .. outputArity
    )
    print()
    print(code)
  end

  return f()
end

function M:init(database, config)
  config = config or {}
  self._database = assert(database)

  self._inputColumns = getColumns(database, config.inputs or {})
  self._optionalInputColumns = getColumns(database, config.optionalInputs or {})
  self._excludedInputColumns = getColumns(database, config.excludedInputs or {})
  self._outputColumns = getColumns(database, config.outputs or {})

  self._sortedInputColumns = values(self._inputColumns)
  self._sortedExcludedInputColumns = values(self._excludedInputColumns)

  self.eachRow = generateEachRowFunction(
    #self._inputColumns,
    #self._optionalInputColumns,
    #self._excludedInputColumns,
    #self._outputColumns
  )
end

function M:sortColumns()
  -- For required inputs, filter rows by smallest column first
  sort(self._sortedInputColumns, function(a, b)
    return a._size < b._size
  end)

  -- For excluded inputs, filter rows by largest column first
  sort(self._sortedExcludedInputColumns, function(a, b)
    return a._size > b._size
  end)
end

return M