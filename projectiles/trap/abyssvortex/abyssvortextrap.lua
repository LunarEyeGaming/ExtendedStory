require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
  self.controlRotation = config.getParameter("controlRotation")
  self.rotationSpeed = 0

  self.aimPosition = mcontroller.position()
  handlerSet = false
end

function update(dt)
  if handlerSet == false then
    message.setHandler("kill", projectile.die)
	handlerSet = true
  end
  if projectile.timeToLive() > 0 then
    projectile.setTimeToLive(0.5)
  end
  if not projectile.sourceEntity() then
    projectile.die()
  end
end
