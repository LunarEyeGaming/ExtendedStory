require "/scripts/vec2.lua"
require "/scripts/util.lua"

function init()
  self.rotateRate = config.getParameter("rotateRate")
  self.rotationAmount = 0
end

function update(dt)
  self.rotationAmount = self.rotationAmount + (self.rotateRate * dt * (2 * math.pi) )

  mcontroller.setRotation(self.rotationAmount)
end
