local M = {}

M.severities =
  { trace = 1, debug = 2, info = 3, warn = 4, error = 5, fatal = 6 }
M.level = "info"

function M.isLogged(level)
  return M.logger and M.severities[level] >= M.severities[M.level]
end

function M.log(level, message)
  if M.isLogged(level) then
    M.logger(level, message)
  end
end

return M
