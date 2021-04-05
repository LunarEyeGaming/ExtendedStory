require "/scripts/vec2.lua"

function init()
  message.setHandler("setTarget", function(_, _, entityId)
    self.target = entityId
  end)
  self.angledProjectileOffset = projectile.getParameter("angledProjectileOffset", {0, 0})
  self.projectileType = projectile.getParameter("projectileType")
end

function update()
  if not self.target or not world.entityExists(self.target) then return end

  local targetPosition = world.entityPosition(self.target)
  if targetPosition then
    local toTarget = world.distance(targetPosition, mcontroller.position())
    local angle = math.atan(toTarget[2], toTarget[1])
    mcontroller.setRotation(angle)
  end

  if projectile.sourceEntity() and not world.entityExists(projectile.sourceEntity()) then
    projectile.die()
  end
end

function destroy()
  if projectile.sourceEntity() and world.entityExists(projectile.sourceEntity()) then
    local rotation = mcontroller.rotation()
    local offset = vec2.rotate(self.angledProjectileOffset, rotation)
    world.spawnProjectile(self.projectileType, vec2.add(mcontroller.position(), offset), projectile.sourceEntity(), {math.cos(rotation), math.sin(rotation)}, false, { power = projectile.power(), powerMultiplier = projectile.powerMultiplier()})
    projectile.processAction(projectile.getParameter("explosionAction"))
  end
end
