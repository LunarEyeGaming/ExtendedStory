function init()
  animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
  animator.setParticleEmitterActive("flames", true)
  effect.setParentDirectives(config.getParameter("directives", ""))

  script.setUpdateDelta(5)

  self.maxHealthTotalChange = 0
  self.tickTime = config.getParameter("tickTime")
  self.tickDamage = config.getParameter("tickDamage")
  self.tickTimer = config.getParameter("initialTickTime", self.tickTime)
end

function update(dt)
  self.tickTimer = math.max(0, self.tickTimer - dt)
  if self.tickTimer == 0 then
    self.tickTimer = self.tickTime
    lightLevel = world.lightLevel(mcontroller.position())
    sb.logInfo("%s", 8 ^ -lightLevel)
    status.modifyResource("health", -self.tickDamage * (8 ^ -lightLevel))
    animator.playSound("sap")
  end
end