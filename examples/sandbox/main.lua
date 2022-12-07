local ffi = require("ffi")
local sparrow = require("sparrow")

ffi.cdef([[
  typedef struct vec2 {
    float x, y;
  } vec2;
]])

local vec2 = ffi.typeof("vec2")

local vec2Mt = {}

vec2Mt.__add = function(a, b)
  return vec2(a.x + b.x, a.y + b.y)
end

vec2Mt.__mul = function(a, b)
  if type(a) == "number" then
    return vec2(a * b.x, a * b.y)
  elseif type(b) == "number" then
    return vec2(a.x * b, a.y * b)
  else
    return vec2(a.x * b.x, a.y * b.y)
  end
end

ffi.metatype("vec2", vec2Mt)

function love.load()
  engine = sparrow.newEngine()

  sparrow.newColumn(engine, "position", "vec2")
  sparrow.newColumn(engine, "velocity", "vec2")

  for i = 1, 20000 do
    local x = love.math.random() * 2 - 1
    local y = love.math.random() * 2 - 1

    local dx = love.math.random() * 2 - 1
    local dy = love.math.random() * 2 - 1

    sparrow.newRow(engine, { position = { x, y }, velocity = { dx, dy } })
  end
end

function love.update(dt)
  local positions = engine:getColumn("position")
  local velocities = engine:getColumn("velocity")

  for i = positions._size - 1, 0, -1 do
    local entity = positions._entities[i]
    local position = positions._values[i]

    if velocities[entity] then
      local velocity = velocities[entity]

      -- position = position + velocity * dt

      position.x = position.x + velocity.x * dt
      position.y = position.y + velocity.y * dt

      positions[entity] = position
    end
  end
end

function love.draw()
  love.graphics.print(love.timer.getFPS())
end
