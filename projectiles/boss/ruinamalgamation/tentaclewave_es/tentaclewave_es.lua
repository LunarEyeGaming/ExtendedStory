require "/scripts/vec2.lua"

function init()
  mcontroller.setRotation(0)
  mcontroller.setVelocity({0, 0})

  self.goalOffset = config.getParameter("goalOffset", {0, 0})
  self.speed = config.getParameter("speed", 0)
  self.timer = config.getParameter("moveDelay", 0.0)

  self.spawn = mcontroller.position()
  self.goal = vec2.add(self.spawn, self.goalOffset)

  message.setHandler("destroy", function(_, _)
    projectile.die()
  end)
end

function update(dt)
  if not world.entityExists(projectile.sourceEntity()) then
    projectile.die()
  end
  
  if self.timer > 0 then
    self.timer = self.timer - dt
    return
  end

  local toGoal = world.distance(self.goal, mcontroller.position())
  local velocity = vec2.mul(vec2.norm(toGoal), self.speed)
  if world.magnitude(toGoal) > world.magnitude(velocity) * dt then
    mcontroller.approachVelocity(velocity, 200)
  else
    projectile.die()
  end
end
