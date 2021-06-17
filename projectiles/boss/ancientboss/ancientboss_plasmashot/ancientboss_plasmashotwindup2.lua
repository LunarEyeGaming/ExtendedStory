require "/scripts/util.lua"

function init()
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
    world.spawnProjectile("ancientboss_plasmashot", mcontroller.position(), projectile.sourceEntity(), {math.cos(rotation), math.sin(rotation)}, false, { speed = 75, power = projectile.getParameter("power")})
    projectile.processAction(projectile.getParameter("explosionAction"))
  end
end
