function init()
  animator.setParticleEmitterOffsetRegion("stonetrail", mcontroller.boundBox())
  animator.setParticleEmitterActive("stonetrail", true)
  effect.setParentDirectives("saturation=-50?fade=2b3137=0.75")

  script.setUpdateDelta(5)
  effect.addStatModifierGroup({
    {stat = "jumpModifier", amount = -0.15}
  })
end

function update(dt)
  mcontroller.controlModifiers({
      groundMovementModifier = 0.3,
      speedModifier = 0.75,
      airJumpModifier = 0.85
    })
end

function uninit()

end
