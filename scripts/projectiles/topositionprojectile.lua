require "/scripts/vec2.lua"
require "/scripts/util.lua"

function init()
  -- param targetOffset
  -- param startingSpeed OR travelTime
  --Script that makes a projectile fly to a specified relative position and then continue its path in the original direction it went.
  self.targetOffset = config.getParameter("targetOffset")
  self.initialSpeed = config.getParameter("startingSpeed")
  self.travelTime = config.getParameter("travelTime")
  self.finalVelocity = mcontroller.velocity() --Velocity that it continues at

  self.targetPosition = vec2.add(mcontroller.position(), self.targetOffset)
  self.spawn = mcontroller.position()
  toGoal = world.distance(self.targetPosition, self.spawn)
  if self.travelTime then
    self.initialSpeed = world.magnitude(self.targetPosition, self.spawn) / self.travelTime
  end

  reachedGoal = false
end

function update(dt)
  toGoal = world.distance(self.targetPosition, mcontroller.position())
  targetVelocity = vec2.mul(vec2.norm(toGoal), self.initialSpeed)
  if not reachedGoal and world.magnitude(toGoal) > world.magnitude(targetVelocity) * dt then
    mcontroller.setVelocity(targetVelocity)
  else
    mcontroller.setVelocity(self.finalVelocity)
    reachedGoal = true
  end
end
