require "/scripts/vec2.lua"

function init()
  self.angledProjectileOffset = projectile.getParameter("angledProjectileOffset", {0, 0})
  self.projectileType = projectile.getParameter("projectileType")
  message.setHandler("kill", function()
    shouldFire = false
    projectile.die()
  end)
  shouldFire = true
end

function update()
  if projectile.sourceEntity() and not world.entityExists(projectile.sourceEntity()) then
    projectile.die()
  end
end

function destroy()
  if shouldFire then
    local rotation = mcontroller.rotation()
    local offset = vec2.rotate(self.angledProjectileOffset, rotation)
    world.spawnProjectile(self.projectileType, vec2.add(mcontroller.position(), offset), projectile.sourceEntity(), {math.cos(rotation), math.sin(rotation)}, false, { power = projectile.power(), powerMultiplier = projectile.powerMultiplier()})
    projectile.processAction(projectile.getParameter("explosionAction"))
  end
end
