require "/scripts/extendedstoryutil.lua"

function init()
  animator.setParticleEmitterOffsetRegion("healing", mcontroller.boundBox())
  animator.setParticleEmitterEmissionRate("healing", config.getParameter("emissionRate", 3))
  animator.setParticleEmitterActive("healing", true)

  script.setUpdateDelta(5)

  self.healingRate = config.getParameter("healAmount", 30) / effect.duration()
end

function update(dt)
  status.modifyResource("health", self.healingRate * dt)
end

function onExpire()

end

function uninit()
  if detectStatusEffect("quickhealnerf_es") then
    status.addEphemeralEffect("quickhealblock_es")
  end
end
