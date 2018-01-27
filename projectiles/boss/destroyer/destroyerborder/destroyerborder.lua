function init()
  message.setHandler("setTarget", function(_, _, entityId)
    self.target = entityId
  end)
  projectileId = entity.id()
  world.setUniqueId(projectileId, "destroyerborder")
end

function update()
  if not self.target or not world.entityExists(self.target) then return end

  local targetPosition = world.entityPosition(self.target)
  message.setHandler("destroyerDefeated", destroy())
  if targetPosition then
    local toTarget = world.distance(targetPosition, mcontroller.position())
    local angle = math.atan(toTarget[2], toTarget[1])
    mcontroller.setRotation(angle)
  end
end

function destroy()
  local rotation = mcontroller.rotation()
  world.spawnProjectile("destroyerlasersweep", mcontroller.position(), projectile.sourceEntity(), {math.cos(rotation), math.sin(rotation)}, false, { speed = 0, power = projectile.getParameter("power")})
end
