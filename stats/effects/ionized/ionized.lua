function init()
  animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
  animator.setParticleEmitterActive("flames", true)
  effect.setParentDirectives("fade=3BD9D7=0.2")

  script.setUpdateDelta(5)

  self.tickTime = 0.75
  self.tickTimer = self.tickTime
  self.damage = 2

  status.applySelfDamageRequest({
      damageType = "IgnoresDef",
      damage = 2,
      damageSourceKind = "ionplasma",
      sourceEntityId = entity.id()
    })
  self.speedModifier = 1
  self.speedFactor = config.getParameter("speedFactor", 0.5)
end

function update(dt)
  self.tickTimer = self.tickTimer - dt
  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime
    self.damage = self.damage + 2
    status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = self.damage,
        damageSourceKind = "ionplasma",
        sourceEntityId = entity.id()
      })
	self.speedModifier = self.speedModifier * self.speedFactor
    mcontroller.controlModifiers({speedModifier = self.speedModifier})
  end
end
