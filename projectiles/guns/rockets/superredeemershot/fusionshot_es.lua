function init()
  self.fuseRadius = config.getParameter("fuseRadius")
  self.explodeAction = config.getParameter("explodeAction")
  self.shouldExplode = true
end

function update(dt)
  queriedGlobes = world.entityQuery(mcontroller.position(), self.fuseRadius, {callScript = "isFusionGlobeEs", includedTypes = {"projectile"}, order = "nearest"})
  if #queriedGlobes > 0 and world.magnitude(world.entityPosition(queriedGlobes[1]), mcontroller.position()) < self.fuseRadius then
    world.sendEntityMessage(queriedGlobes[1], "triggerLargeDetonation")
    self.shouldExplode = false
    projectile.die()
  end
end

function destroy()
  if self.shouldExplode then
    projectile.processAction(self.explodeAction)
  end
end