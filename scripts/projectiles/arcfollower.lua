require "/scripts/vec2.lua"
require "/scripts/util.lua"

function init()
  self.turnRate = util.randomInRange(config.getParameter("turnRate", 0)) * 2 * math.pi
end

function update(dt)
  local velocity = mcontroller.velocity()
  velocity = vec2.rotate(velocity, self.turnRate * dt)
  mcontroller.setVelocity(velocity)
end