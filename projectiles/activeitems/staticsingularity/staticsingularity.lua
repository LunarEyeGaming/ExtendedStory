function init()
  self.broadcastedOverride = false
  self.overrideRadius = config.getParameter("overrideRadius")
  
  message.setHandler("newSingularityEs", projectile.die)
end

function update(dt)
  if not self.broadcastedOverride then
    queried = world.entityQuery(mcontroller.position(), self.overrideRadius, {
      callScript = "isSingularityEs",
      includedTypes = {"projectile"},
      withoutEntityId = entity.id()
    })
    for _, entityId in pairs(queried) do
      world.sendEntityMessage(entityId, "newSingularityEs")
    end
    self.broadcastedOverride = true
  end
end

function isSingularityEs()
  return true
end