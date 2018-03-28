require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
  self.controlRotation = config.getParameter("controlRotation")
  self.rotationSpeed = 0

  self.aimPosition = mcontroller.position()

  message.setHandler("attack", attack(dt))
  message.setHandler("stop", projectile.die())
end

function update(dt)
  if projectile.timeToLive() > 0 then
    projectile.setTimeToLive(0.5)
  end
end

function attack(dt)
  projectile.setTimeToLive(0)
end
