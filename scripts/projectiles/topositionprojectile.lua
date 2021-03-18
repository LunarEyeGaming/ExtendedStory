require "/scripts/vec2.lua"
require "/scripts/util.lua"

function init()
  -- param targetOffset
  -- param startingSpeed OR travelTime
  --Script that makes a projectile fly to a specified relative position and then continue its path in the original direction it went.
  self.targetOffsetRange = config.getParameter("targetOffsetRange")
  self.targetPosition = config.getParameter("targetPosition")
  if self.targetOffsetRange then
    self.targetOffset = {
      util.randomIntInRange({self.targetOffsetRange[1], self.targetOffsetRange[3]}), 
      util.randomIntInRange({self.targetOffsetRange[2], self.targetOffsetRange[4]})
    }
  else
    self.targetOffset = config.getParameter("targetOffset")
  end
  self.initialSpeed = config.getParameter("startingSpeed")
  self.travelTime = config.getParameter("travelTime")
  self.finalVelocity = mcontroller.velocity() --Velocity that it continues at

  self.targetPosition = self.targetPosition or vec2.add(mcontroller.position(), self.targetOffset)
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
