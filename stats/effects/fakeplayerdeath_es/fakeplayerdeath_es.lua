function init()
  animator.burstParticleEmitter("death")
  effect.setParentDirectives("?multiply=ffffff00")
  
  status.setResource("health", 1)
  status.setResourcePercentage("energyRegenBlock", 1.0)
  status.addEphemeralEffects({{effect = "invulnerable", duration = effect.duration()}, {effect = "healimpairedinvisible_es", duration = effect.duration()}, {effect = "antimatterfreezeinvisible", duration = effect.duration()}})
  self.cinematicPath = config.getParameter("cinematicPath")
  self.cinematicDelay = config.getParameter("cinematicDelay")

  self.cinematicTimer = self.cinematicDelay
  self.playedCinematic = false
end

function update(dt)
  status.setResourcePercentage("energyRegenBlock", 1.0)
  self.cinematicTimer = math.max(0, self.cinematicTimer - dt)
  local cinematic = string.format(self.cinematicPath, world.entitySpecies(entity.id()))
  if self.cinematicTimer == 0 and not self.playedCinematic then
    world.sendEntityMessage(entity.id(), "playCinematic", cinematic)
    self.playedCinematic = true
  end
end

function onExpire()
  status.setResourcePercentage("health", 1)
  status.setResourcePercentage("energy", 1)
  status.setResourcePercentage("energyRegenBlock", 0.0)
end