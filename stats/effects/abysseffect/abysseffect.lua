function init()
  animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
  animator.setParticleEmitterActive("flames", true)
  effect.setParentDirectives("brightness=-75")

  script.setUpdateDelta(5)

  self.tickTime = config.getParameter("tickTime")
  self.maxHealthChange = config.getParameter("maxHealthChange")
  self.tickTimer = config.getParameter("initialTickTime", self.tickTime)
  healingMultiplier = config.getParameter("healingMultiplier", 0)
end

function update(dt)
  self.tickTimer = math.max(0, self.tickTimer - dt)
  if self.tickTimer == 0 then
    self.tickTimer = self.tickTime
    
  end
  oldHealthAmount = currentHealthAmount or status.resource("health")
  currentHealthAmount = status.resource("health")
  healthLost = -healingMultiplier * math.max((currentHealthAmount - oldHealthAmount), 0)
  status.modifyResource("health", healthLost)
end
