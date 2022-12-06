local sparrow = require("sparrow")

function love.load()
  engine = sparrow.newEngine()

  sparrow.newColumn(engine, "position")
  sparrow.newColumn(engine, "velocity")

  row = sparrow.newRow(engine, { position = { 1, 2 }, velocity = { 3, 4 } })
end
