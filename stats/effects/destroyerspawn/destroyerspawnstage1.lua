function init()
  world.sendEntityMessage(entity.id(), "queueRadioMessage", "destroyerspawn")
  animator.setParticleEmitterActive("sparks", true)

  effect.setParentDirectives(config.getParameter("directives", ""))

  self.movementModifiers = config.getParameter("movementModifiers", {})

  self.energyCost = config.getParameter("energyCost", 1)
  self.healthDamage = config.getParameter("healthDamage", 1)
  
  script.setUpdateDelta(config.getParameter("tickRate", 1))
  if (world.type() == "unknown" or world.isTileProtected(mcontroller.position())) then
    effect.expire()
  end
end

function update(dt)
  mcontroller.controlModifiers(self.movementModifiers)
end

function onExpire()
  status.addEphemeralEffect("destroyerspawnstage2")
end