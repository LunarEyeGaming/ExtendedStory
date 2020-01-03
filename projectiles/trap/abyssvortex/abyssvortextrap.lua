require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
  message.setHandler("kill", projectile.die)
  self.controlRotation = config.getParameter("controlRotation")
  self.rotationSpeed = 0

  self.aimPosition = mcontroller.position()
end

function update(dt)
  if projectile.timeToLive() > 0 then
    projectile.setTimeToLive(0.5)
  end
  if not (projectile.sourceEntity() and world.entityExists(projectile.sourceEntity())) then
    projectile.die()
  end
end
