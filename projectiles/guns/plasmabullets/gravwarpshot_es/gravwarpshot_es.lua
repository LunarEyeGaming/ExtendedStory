function init()
  self.deadCollisionAction = config.getParameter("deadCollisionAction")
end

function update(dt)
end

function destroy()
  --[[do
    local nearestMonsterQuery = world.entityQuery(mcontroller.position())
    sb.logInfo("[Extended Story Debug] Nearest Monster Proximity = %s", projectile.collision())
  end]]
  if mcontroller.isColliding() then
    projectile.processAction(self.deadCollisionAction)
  end
end