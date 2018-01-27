function init()
  animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
  animator.setParticleEmitterActive("flames", true)
  effect.setParentDirectives("fade=FFFFFF=0.2")

  script.setUpdateDelta(5)

  self.tickTime = 0.75
  self.tickTimer = self.tickTime
  self.damage = 16

  status.applySelfDamageRequest({
      damageType = "IgnoresDef",
      damage = 4,
      damageSourceKind = "abyss",
      sourceEntityId = entity.id()
    })
end

function update(dt)
  self.tickTimer = self.tickTimer - dt
  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime
    self.damage = self.damage
    status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = self.damage,
        damageSourceKind = "abyss",
        sourceEntityId = entity.id()
      })
  end
end
