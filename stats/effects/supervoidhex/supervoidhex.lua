function init()
  --Damage reduction
  self.powerModifier = config.getParameter("powerModifier", 0)
  effect.addStatModifierGroup({{stat = "powerMultiplier", effectiveMultiplier = self.powerModifier}})

  healingMultiplier = config.getParameter("healingMultiplier", 0)

  local enableParticles = config.getParameter("particles", true)
  animator.setParticleEmitterOffsetRegion("embers", mcontroller.boundBox())
  animator.setParticleEmitterActive("embers", enableParticles)
end


function update(dt)
  oldHealthAmount = currentHealthAmount or status.resource("health")
  currentHealthAmount = status.resource("health")
  healthLost = -healingMultiplier * math.max((currentHealthAmount - oldHealthAmount), 0)
  status.modifyResource("health", healthLost)
end

function uninit()

end
