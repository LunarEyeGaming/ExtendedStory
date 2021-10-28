function init()
  animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
  animator.setParticleEmitterActive("flames", true)
  effect.setParentDirectives("brightness=-75")

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
  healingMultiplier = config.getParameter("healingMultiplier", 0)
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
  oldHealthAmount = currentHealthAmount or status.resource("health")
  currentHealthAmount = status.resource("health")
  healthLost = -healingMultiplier * math.max((currentHealthAmount - oldHealthAmount), 0)
  status.modifyResource("health", healthLost)
end
