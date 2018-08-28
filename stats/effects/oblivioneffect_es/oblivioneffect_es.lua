function init()
  animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
  animator.setParticleEmitterActive("flames", true)
  effect.setParentDirectives("brightness=-75")

  script.setUpdateDelta(5)

  self.tickTime = 0.25
  self.tickTimer = self.tickTime
  self.damage = 15

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
