local ffi = require("ffi")
local sparrow = require("sparrow")

local insert = assert(table.insert)

local function slice(t, i, j, result)
  i = i or 1
  j = j or #t
  result = result or {}

  for k = i, j do
    insert(result, t[k])
  end

  return result
end

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
  sparrow.newColumn(engine, "acceleration", "vec2")

  updatePositionQuery = sparrow.newQuery(
    engine,
    { "position", "velocity" },
    {},
    { "position" }
  )

  components = { "position", "velocity", "acceleration" }

  for inputArity = 1, 3 do
    for unputArity = 0, 3 do
      for outputArity = 0, 3 do
        sparrow.newQuery(
          engine,
          slice(components, 1, inputArity),
          slice(components, 1, unputArity),
          slice(components, 1, outputArity)
        )
      end
    end
  end
end

function love.update(dt)
  for i = 1, 100 do
    if engine._nextEntity <= 100000 then
      local x = love.math.random() * 2 - 1
      local y = love.math.random() * 2 - 1

      local dx = love.math.random() * 2 - 1
      local dy = love.math.random() * 2 - 1

      sparrow.newRow(engine, { position = { x, y }, velocity = { dx, dy } })
    end
  end

  updatePositionQuery:forEach(function(position, velocity)
    -- position = position + velocity * dt

    position.x = position.x + velocity.x * dt
    position.y = position.y + velocity.y * dt

    return position
  end)
end

function love.draw()
  love.graphics.print(
    love.timer.getFPS() .. " FPS, " .. (engine._nextEntity - 1) .. " entities"
  )
end
