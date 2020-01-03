function init()
  animator.setParticleEmitterOffsetRegion("healing", mcontroller.boundBox())
  animator.setParticleEmitterEmissionRate("healing", config.getParameter("emissionRate", 3))
  animator.setParticleEmitterActive("healing", true)
  if not status.statPositive("healingStatusImmunity") then
    status.modifyResource("health", config.getParameter("healAmount", 30))
  end
end

function update(dt)
end

function onExpire()
  status.addEphemeralEffect(config.getParameter("cooldownEffect"))
end
