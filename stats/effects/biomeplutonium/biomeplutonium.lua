function init()
  effect.setParentDirectives(config.getParameter("directives", ""))
  world.sendEntityMessage(entity.id(), "queueRadioMessage", "biomeplutonium", 5.0)
  self.healthPercentage = config.getParameter("healthPercentage", 0.1)
  timer = 0
end

function update(dt)
  status.setResourcePercentage("health", math.min(status.resourcePercentage("health"), self.healthPercentage))
  timer = timer + dt
  if timer >= 20 then
    effect.setParentDirectives("fade=AAFF88FF;0.30")
  end
  if timer >= 40 then
    effect.setParentDirectives("fade=AAFF88FF;0.45")
  end
  if timer >= 50 then
    effect.setParentDirectives("fade=AAFF88FF;0.70")
  end
  if timer >= 55 then
    effect.setParentDirectives("fade=AAFF88FF;0.85")
  end
  if timer >= 60 then
    status.setResourcePercentage("health", 0)
  end
end

function uninit()

end
