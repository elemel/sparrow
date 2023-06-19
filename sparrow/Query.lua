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

    if not column and component ~= "entity" then
      error("No such column: " .. component)
    end

    columns[i] = column
  end

  return columns
end

local function generateForEachCode(
  inclusions,
  exclusions,
  arguments,
  results,
  buffer
)
  assert(#inclusions >= 1, "Not implemented")
  buffer = buffer or {}

  insert(
    buffer,
    [[
return function(query, system)
  query:prepare()
  query:_sortColumns()

  for i = query._sortedInclusionColumns[1]:getSize() - 1, 0, -1 do
    local entity = query._sortedInclusionColumns[1]:getEntity(i)

    if ]]
  )

  if #inclusions == 1 and #exclusions == 0 then
    insert(buffer, "true")
  else
    for i = 2, #inclusions do
      if i >= 3 then
        insert(buffer, " and\n        ")
      end

      insert(buffer, "query._sortedInclusionColumns[")
      insert(buffer, i)
      insert(buffer, "]:getIndex(entity)")
    end

    for i = 1, #exclusions do
      if #inclusions >= 2 or i >= 2 then
        insert(buffer, " and\n        ")
      end

      insert(buffer, "not query._sortedExclusionColumns[")
      insert(buffer, i)
      insert(buffer, "]:getIndex(entity)")
    end
  end

  insert(buffer, " then\n      ")

  if #results >= 1 then
    insert(buffer, "local ")

    for i = 1, #results do
      if i >= 2 then
        insert(buffer, ",\n        ")
      end

      insert(buffer, "result")
      insert(buffer, i)
    end

    insert(buffer, " = ")
  end

  insert(buffer, "system(")

  for i = 1, #arguments do
    if i >= 2 then
      insert(buffer, ",\n          ")
    end

    if arguments[i] == "entity" then
      insert(buffer, "entity")
    else
      insert(buffer, "query._argumentColumns[")
      insert(buffer, i)
      insert(buffer, "]:getCell(entity)")
    end
  end

  insert(buffer, ")\n")

  if #results >= 1 then
    for i = 1, #results do
      insert(buffer, "      query._resultColumns[")
      insert(buffer, i)
      insert(buffer, "]:setCell(entity, result")
      insert(buffer, i)
      insert(buffer, ")\n")
    end
  end

  insert(
    buffer,
    [[
    end
  end
end
]]
  )

  return buffer
end

function M:init(database, config)
  self._database = assert(database)

  self._version = 0
  assert(self._version ~= self._database._version)

  self._inclusions = copy(config.inclusions or {})
  self._exclusions = copy(config.exclusions or {})

  self._arguments = copy(config.arguments or {})
  self._results = copy(config.results or {})

  local buffer = generateForEachCode(
    self._inclusions,
    self._exclusions,
    self._arguments,
    self._results
  )

  self._forEachCode = concat(buffer)
  local f, message = load(self._forEachCode)

  if message then
    error(message .. "\n\n" .. self._forEachCode)
  end

  self.forEach = f()
  self:prepare()
end

function M:getDatabase()
  return self._database
end

function M:getVersion()
  return self._version
end

function M:getForEachCode()
  return self._forEachCode
end

function M:prepare()
  if self._version ~= self._database._version then
    self._inclusionColumns = getColumns(self._database, self._inclusions or {})
    self._exclusionColumns = getColumns(self._database, self._exclusions or {})

    self._argumentColumns = getColumns(self._database, self._arguments or {})
    self._resultColumns = getColumns(self._database, self._results or {})

    self._sortedInclusionColumns = values(self._inclusionColumns)
    self._sortedExclusionColumns = values(self._exclusionColumns)

    self._version = self._database._version
  end
end

function M:_sortColumns()
  -- For inclusions, filter rows by smallest column first
  sort(self._sortedInclusionColumns, function(a, b)
    return a._size < b._size
  end)

  -- For exclusions, filter rows by largest column first
  sort(self._sortedExclusionColumns, function(a, b)
    return a._size > b._size
  end)
end

return M
