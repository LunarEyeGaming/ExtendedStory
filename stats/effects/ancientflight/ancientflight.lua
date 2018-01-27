function init()
  animator.setParticleEmitterOffsetRegion("icetrail", mcontroller.boundBox())
  animator.setParticleEmitterActive("icetrail", true)
  effect.setParentDirectives("fade=00BBFF=0.15")
  self.flightMovement = config.getParameter("flightMovement")

  script.setUpdateDelta(5)

  effect.addStatModifierGroup({
    {stat = "jumpModifier", amount = -0.15}
  })
end

function update(dt)
  mcontroller.controlParameters(self.flightMovement)
  mcontroller.controlModifiers({
      groundMovementModifier = 10,
      speedModifier = 50.0,
      airJumpModifier = 50.0
    })
end

function onExpire()
  mcontroller.baseParameters()
end
