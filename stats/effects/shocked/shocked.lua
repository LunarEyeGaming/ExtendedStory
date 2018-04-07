function init()
  animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
  animator.setParticleEmitterActive("flames", true)

  script.setUpdateDelta(5)

  self.tickTime = 0.75
  self.tickTimer = self.tickTime
  self.damage = 30
end

function update(dt)
  self.tickTimer = self.tickTimer - dt
  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime
    self.damage = self.damage
    status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = self.damage,
        damageSourceKind = "megadamageelectric",
        sourceEntityId = entity.id()
      })
  end
end
