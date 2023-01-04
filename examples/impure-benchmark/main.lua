local ffi = require("ffi")
local sparrow = require("sparrow")

ffi.cdef([[
  typedef struct vec2 {
    float x, y;
  } vec2;
]])

local database
local query

function love.load()
  database = sparrow.newDatabase()

  sparrow.newColumn(database, "position", "vec2")
  sparrow.newColumn(database, "velocity", "vec2")

  query = sparrow.newQuery(database, {
    inclusions = { "position", "velocity" },
    arguments = { "position", "velocity" },
  })
end

function love.update(dt)
  for i = 1, 100 do
    if database:getRowCount() < 1000000 then
      local x = love.math.random() * 2 - 1
      local y = love.math.random() * 2 - 1

      local dx = love.math.random() * 2 - 1
      local dy = love.math.random() * 2 - 1

      sparrow.newRow(database, { position = { x, y }, velocity = { dx, dy } })
    end
  end

  query:forEach(function(position, velocity)
    position.x = position.x + velocity.x * dt
    position.y = position.y + velocity.y * dt
  end)
end

function love.draw()
  love.graphics.print(
    love.timer.getFPS() .. " FPS, " .. database:getRowCount() .. " rows"
  )
end
