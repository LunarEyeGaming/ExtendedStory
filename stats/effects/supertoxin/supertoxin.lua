function init()
  local bounds = mcontroller.boundBox()
  
  script.setUpdateDelta(2)

  self.tickRate = config.getParameter("tickRate")
  self.tickDamage = config.getParameter("tickDamage")

  self.tickTimer = self.tickRate
end

function update(dt)
  self.tickTimer = math.max(0, self.tickTimer - dt)
  if self.tickTimer == 0 then
    animator.burstParticleEmitter("sparks")
    self.tickTimer = self.tickRate
    status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = self.tickDamage,
        damageSourceKind = "poison",
        sourceEntityId = entity.id()
      })
  end
end

function uninit()

end