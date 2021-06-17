function init()
  animator.setParticleEmitterOffsetRegion("icetrail", mcontroller.boundBox())
  animator.setParticleEmitterActive("icetrail", true)
  effect.setParentDirectives("fade=00BBFF=0.15")
  self.flightMovement = config.getParameter("flightMovement")

  --sb.logInfo("%s", mcontroller.baseParameters())
  --script.setUpdateDelta(5)
end

function update(dt)
  mcontroller.controlParameters(self.flightMovement)
  world.debugText("Running: %s, Direction: %s\nCrouching: %s\nJumping: %s", mcontroller.running(), mcontroller.movingDirection(), mcontroller.crouching(), mcontroller.jumping(), mcontroller.position(), "green")
  --[[mcontroller.controlModifiers({
      groundMovementModifier = 10,
      speedModifier = 50.0,
      airJumpModifier = 50.0
    })]]
end

function onExpire()
end
