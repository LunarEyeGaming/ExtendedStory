function init()
  animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
  animator.setParticleEmitterActive("flames", true)
  effect.setParentDirectives("fade=D29CE7=0.2")

  script.setUpdateDelta(5)

  self.tickTime = 2
  self.tickTimer = self.tickTime
  self.damage = 8

  status.applySelfDamageRequest({
      damageType = "IgnoresDef",
      damage = 2,
      damageSourceKind = "plasma",
      sourceEntityId = entity.id()
    })
end

function update(dt)
  self.tickTimer = self.tickTimer - dt
  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime
    status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = self.damage,
        damageSourceKind = "plasma",
        sourceEntityId = entity.id()
      })
  end
end
