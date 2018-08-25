function init()
  animator.setParticleEmitterOffsetRegion("sparks", mcontroller.boundBox())
  self.soundInterval = config.getParameter("soundInterval")
  effect.setParentDirectives("saturation=-100")
  self.soundTimer = 0

  self.tickTime = 1.0
  self.tickTimer = self.tickTime
  self.timer = 0
  self.compoundDamage = config.getParameter("starvationCompoundDamage", 1)
  self.movementModifiers = config.getParameter("movementModifiers", {})
end

function update(dt)

  self.timer = self.timer + dt
  local tickDamage = self.compoundDamage * dt
  status.modifyResource("health", -tickDamage)
  mcontroller.controlModifiers(self.movementModifiers)
end

function uninit()

end
