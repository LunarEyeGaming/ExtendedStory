require "/scripts/vec2.lua"
require "/scripts/util.lua"

function init()
  self.turnRate = util.randomInRange(config.getParameter("turnRate", 0)) * 2 * math.pi
  if self.turnRate > 0 then
    self.capFunc = math.max
  else
    self.capFunc = math.min
  end
  self.turnEndTime = config.getParameter("turnEndTime")
  self.turnChangeRate = self.turnRate / self.turnEndTime
end

function update(dt)
  self.turnRate = self.capFunc(0, self.turnRate - self.turnChangeRate * dt)
  local velocity = mcontroller.velocity()
  velocity = vec2.rotate(velocity, self.turnRate * dt)
  mcontroller.setVelocity(velocity)
end