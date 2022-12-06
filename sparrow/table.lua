local M = {}

function M.copy(source, target)
  target = target or {}

  for k, v in pairs(source) do
    target[k] = v
  end

  return target
end

return M
