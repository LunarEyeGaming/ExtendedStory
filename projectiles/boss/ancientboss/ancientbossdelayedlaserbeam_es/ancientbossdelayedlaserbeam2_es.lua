require "/scripts/vec2.lua"

function init()
  message.setHandler("delayedlaserbeam2_fire", function(_, _, entityId)
    trigger()
    projectile.die()
  end)
  message.setHandler("kill", projectile.die)
  self.angledProjectileOffset = projectile.getParameter("angledProjectileOffset", {0, 0})
  self.projectileType = projectile.getParameter("projectileType")
  self.firing = false
end

function update()
  if projectile.timeToLive() > 0 then
    projectile.setTimeToLive(0.5)
  end

  if projectile.sourceEntity() and not world.entityExists(projectile.sourceEntity()) then
    projectile.die()
  end
end

function trigger()
  local rotation = mcontroller.rotation()
  world.spawnProjectile(
    self.projectileType,
    vec2.add(mcontroller.position(), vec2.rotate(self.angledProjectileOffset, rotation)),
    projectile.sourceEntity(),
    {math.cos(rotation), math.sin(rotation)},
    false,
    { power = projectile.power(), powerMultiplier = projectile.powerMultiplier() }
  )
  projectile.processAction(projectile.getParameter("explosionAction"))
end
