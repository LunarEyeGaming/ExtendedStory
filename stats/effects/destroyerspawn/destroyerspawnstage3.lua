function init()
  animator.setParticleEmitterActive("sparks", true)

  effect.setParentDirectives(config.getParameter("directives", ""))

  self.movementModifiers = config.getParameter("movementModifiers", {})

  self.energyCost = config.getParameter("energyCost", 1)
  self.healthDamage = config.getParameter("healthDamage", 1)
  
  script.setUpdateDelta(config.getParameter("tickRate", 1))
end

function update(dt)
  mcontroller.controlModifiers(self.movementModifiers)
end

function onExpire()
  status.addEphemeralEffect("destroyerspawnstage4")
end