require "/scripts/interp.lua"
require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
  self.travelTime = config.getParameter("travelTime")
  self.maxRotateRate = config.getParameter("maxRotateRate")
  self.minRotateRate = config.getParameter("minRotateRate")

  self.travelTimer = self.travelTime
  
  local sourceEntityPosition = world.entityPosition(projectile.sourceEntity())
  
  self.initialSourceOffset = world.distance(mcontroller.position(), sourceEntityPosition)
  self.targetSourceOffset = world.distance(config.getParameter("targetPosition"), sourceEntityPosition)

  self.rotateRate = self.minRotateRate
  self.rotationAmount = 0
end

function update(dt)
  self.travelTimer = math.max(0, self.travelTimer - dt)
  --targetVelocity = vec2.mul(vec2.norm(toGoal), interp.sin(self.initialSpeed))
  local ratio = 1 - (self.travelTimer / self.travelTime)

  self.rotateRate = interp.linear(ratio, self.minRotateRate, self.maxRotateRate)
  self.rotationAmount = self.rotationAmount + (self.rotateRate * dt * (2 * math.pi) )
  mcontroller.setRotation(self.rotationAmount)

  if self.travelTimer == 0 then
    projectile.die()
  else
    local sourceEntityPosition = world.entityPosition(projectile.sourceEntity())
    local initialPosition = vec2.add(sourceEntityPosition, self.initialSourceOffset)
    local targetPosition = vec2.add(sourceEntityPosition, self.targetSourceOffset)

    mcontroller.setPosition({interp.sin(ratio, initialPosition[1], targetPosition[1]), interp.sin(ratio, initialPosition[2], targetPosition[2])})
  end
end
