function init()
  animator.setParticleEmitterOffsetRegion("shards", mcontroller.boundBox())
  animator.burstParticleEmitter("shards")
  effect.setParentDirectives("saturation=-100?fade=2b3137=0.75")
  animator.playSound("stoned")
  animator.setAnimationRate(0)
  effect.addStatModifierGroup({
    {stat = "invulnerable", amount = 1},
    {stat = "fireStatusImmunity", amount = 1},
    {stat = "iceStatusImmunity", amount = 1},
    {stat = "electricStatusImmunity", amount = 1},
    {stat = "poisonStatusImmunity", amount = 1},
    {stat = "powerMultiplier", effectiveMultiplier = 0}
  })

  if status.isResource("stunned") then
    status.setResource("stunned", math.max(status.resource("stunned"), effect.duration()))
  end
  world.sendEntityMessage(entity.id(), "playCinematic", "/cinematics/slowfade.cinematic")
end

function update(dt)
  mcontroller.controlModifiers({
      facingSuppressed = true,
      movementSuppressed = true,
      groundMovementModifier = 0.0,
      speedModifier = 0.0,
      airJumpModifier = 0.0
    })
end

function onExpire()
  animator.setAnimationRate(1)
  status.setResourcePercentage("health", 0)
end
