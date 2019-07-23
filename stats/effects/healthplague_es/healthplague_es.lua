function init()
  animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
  animator.setParticleEmitterActive("flames", true)
  effect.setParentDirectives("fade=D45353=0.25")
  
  script.setUpdateDelta(5)

  self.tickDamagePercentage = 0.1
  self.tickTime = 1.0
  self.tickTimer = self.tickTime
end

function update(dt)

  self.tickTimer = self.tickTimer - dt
  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime
    status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = math.ceil(status.resourceMax("health") * self.tickDamagePercentage),
        damageSourceKind = "default",
        sourceEntityId = entity.id()
      })
  end
end

function uninit()
  
end
