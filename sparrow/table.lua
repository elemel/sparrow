local insert = assert(table.insert)

local M = {}

function M.copy(source, target)
  target = target or {}

  for k, v in pairs(source) do
    target[k] = v
  end

  return target
end

function M.values(t, result)
  result = result or {}

  for _, v in pairs(t) do
    insert(result, v)
  end

  return result
end

return M
