function init()
  initialDuration = effect.duration()
  self.startingInstanceWorld = config.getParameter("startingInstanceWorld")
  self.endingInstanceWorld = config.getParameter("endingInstanceWorld")
  self.loadingCinematic = config.getParameter("loadingCinematic", "/cinematics/loading2_es.cinematic")
  self.loadingEndCinematic = config.getParameter("loadingEndCinematic", "/cinematics/fadeout_es.cinematic")
  self.cinematicEndDelay = config.getParameter("cinematicEndDelay", 1.0)

  self.cinematicEndTimer = self.cinematicEndDelay
  self.playedEndCinematic = false
  
  if world.type() == self.startingInstanceWorld then
    world.sendEntityMessage(entity.id(), "playCinematic", self.loadingCinematic)
    world.sendEntityMessage(entity.id(), "warp", "InstanceWorld:"..self.endingInstanceWorld)
  end
end

function update(dt)
  self.cinematicEndTimer = math.max(0, self.cinematicEndTimer - dt)
  currentDuration = effect.duration()
  if currentDuration <= initialDuration and currentDuration > 0 then
    effect.modifyDuration(initialDuration - currentDuration)
  end

  -- Because init() is called after switching to a new instance world but before the player script can receive entity messages.
  if self.cinematicEndTimer == 0 and not self.playedEndCinematic and world.type() == self.endingInstanceWorld then
    world.sendEntityMessage(entity.id(), "playCinematic", self.loadingEndCinematic)
    effect.expire()
    self.playedEndCinematic = true
  end
end

function onExpire()
end