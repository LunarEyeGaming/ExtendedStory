function init()
  message.setHandler("triggerLargeDetonation", function()
    self.useLargeDetonation = true
    projectile.die()
  end)
  self.useLargeDetonation = false
  self.largeDetonationAction = config.getParameter("largeDetonationAction")
  self.detonationAction = config.getParameter("detonationAction")
end

function update(dt)
  
end

function isFusionGlobeEs()
  return true
end

function destroy()
  if self.useLargeDetonation then
    projectile.processAction(self.largeDetonationAction)
  else
    projectile.processAction(self.detonationAction)
  end
end