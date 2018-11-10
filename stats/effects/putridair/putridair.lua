function init()
  world.sendEntityMessage(entity.id(), "queueRadioMessage", "putridair", 1.0)
  animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
  animator.setParticleEmitterActive("flames", true)
  effect.setParentDirectives("fade=638700=0.2")

  script.setUpdateDelta(5)

  self.tickTime = 0.5
  self.tickTimer = self.tickTime
  self.damage = 2
end

function update(dt)
  self.tickTimer = self.tickTimer - dt
  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime
    status.modifyResource("health", -self.damage)
  end
end
